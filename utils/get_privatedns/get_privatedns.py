#!/usr/bin/env python
"""
Script to download and load NS1 Enterprise DDI & Private DNS docker images.

By default this will download the latest version of all available images.
"""
from __future__ import print_function, division
import socket
import sys
import os
import json
import argparse
import subprocess
from timeit import default_timer

try:
    import urllib2
except ModuleNotFoundError:
    # Python 3 compatibility
    import urllib.request as urllib2


DEBUG = False


class Cursor(object):
    def __init__(self):
        self.shown = True
    
    def toggle_cursor(self):
        esc_seq = "\033[?25l" if self.shown else "\033[?25h"
        print_stderr(esc_seq, end="")
        sys.stderr.flush()
        self.shown = not self.shown

    def hide_cursor(self):
        if self.shown:
            self.toggle_cursor()

    def show_cursor(self):
        if not self.shown:
            self.toggle_cursor()
CURSOR = Cursor()

def print_stderr(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def print_debug(*args, **kwargs):
    if DEBUG:
        print_stderr("DEBUG:", *args, **kwargs)


def unix_socket_request(method, endpoint, file_name=None, verbose=False):
    # type: (str, str, Optional[str], bool) -> str
    """
    Given an HTTP method and an endpoint, makes an HTTP request to the Docker
    engine API over an UNIX socket. Returns the response body.
    """
    msg_body = b""
    # Create a UDS socket
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    # Connect the socket to the port where the server is listening
    server_address = "/var/run/docker.sock"
    if verbose or DEBUG:
        print_debug("connecting to {}".format(server_address))
    try:
        sock.connect(server_address)
    except socket.error:
        print_stderr("Could not connect to the Docker daemon... is it running?")
        sys.exit(1)

    try:
        # Send data
        http_req = "{} {} HTTP/1.1\r\nHost: v1.24\r\n".format(method, endpoint)
        if file_name is not None:
            file_size = os.stat(file_name).st_size
            http_req += "Content-Type: application/x-tar\r\nContent-Length: {}\r\n".format(
                file_size
            )
        http_req_bytes = (http_req + "\r\n").encode()

        if verbose or DEBUG:
            for line in http_req.split("\n"):
                print_debug("> {}".format(line))
        sock.sendall(http_req_bytes)

        if file_name is not None:
            start = default_timer()
            bytes_sent = 0
            with open(file_name, "rb") as fin:
                CHUNK = 1024 * 1024
                chunk = fin.read(CHUNK)
                print("Loading {} into Docker".format(file_name))
                while chunk:
                    sock.sendall(chunk)
                    bytes_sent += len(chunk)
                    overall_rate = bytes_sent * 8 / (default_timer() - start)
                    make_progress_bar(bytes_sent, file_size, overall_rate)
                    chunk = fin.read(CHUNK)
                    if not chunk:
                        make_progress_bar(bytes_sent, file_size, overall_rate, complete=True)

        # receive the response
        amount_received = 0
        max_amount = 2 ** 16
        header = b""
        while amount_received < max_amount:
            header += sock.recv(1)
            if header[-4:] == b"\r\n\r\n":
                if "content-length" in header.decode().lower():
                    for h in header.decode().split("\n"):
                        if "content-length" in h.lower():
                            remaining_bytes = int(h.split(":")[-1])
                            msg_body = sock.recv(remaining_bytes)
                    if msg_body:
                        break
                else:
                    # some versions of the Docker engine API don't always
                    # include a content-length header and instead just send
                    # a hex number indicating the body length
                    remaining_msg = b""
                    last_char = sock.recv(1)
                    while last_char != b"\r":
                        remaining_msg += last_char
                        last_char = sock.recv(1)
                    msg_body = sock.recv(int(remaining_msg.decode(), 16))
                    break
            amount_received += 1
    except Exception as e:
        print_stderr("Could not connect to the Docker daemon... is it running?", e)
    finally:
        sock.close()
        if verbose or DEBUG:
            for line in header.decode().split("\n"):
                print_debug("<", line)
            print_stderr(msg_body.decode().strip())
    return msg_body.decode().strip()


def authenticated_ns1_request(apikey, endpoint, file_name=None):
    # type: (str, str, Optional[str]) -> Dict[str, Union[Optional[str], Dict[str, str]]]
    """
    Given an API key and an endpoint, makes an API request to the NS1 API. Given
    a `file_name` argument it will write the response to a file on disk instead
    of returning it.

    Returns a dict with keys: "content" and "headers". "content" contains the
    API response body (unless the `file_name` arg was given). "headers" is a
    dict with string keys and string values - each key value pair is an HTTP
    response header.
    """
    url = "https://api.nsone.net/v1" + endpoint
    auth_header = {"X-NSONE-Key": apikey}
    req = urllib2.Request(url, headers=auth_header)
    response = urllib2.urlopen(req)
    headers = dict(response.headers)
    if DEBUG:
        print_debug("Making NS1 API request to", url)
        print_debug("> GET /v1", endpoint, "HTTP/1.1")
        print_debug("> Host: api.nsone.net")
        print_debug("> x-nsone-key:", apikey)
        print_debug(">")
    if file_name is None:
        content = response.read()
    else:
        content = None
        CHUNK = 16 * 1024
        start = default_timer()
        with open(file_name, "wb") as f:
            total_size = int(
                headers.get("Content-Length") or headers.get("content-length")
            )
            total_dl = 0
            overall_rate = 0.0
            while True:
                chunk = response.read(CHUNK)
                if not chunk:
                    make_progress_bar(total_dl, total_size, overall_rate, complete=True)
                    break
                total_dl += CHUNK
                overall_rate = total_dl * 8 / (default_timer() - start)
                make_progress_bar(total_dl, total_size, overall_rate)
                f.write(chunk)
    for header in headers:
        print_debug("<", header, ":", headers[header])
    print_debug("<")
    print_debug(content or "file downloaded")
    return {
        "body": content,
        "headers": headers,
    }


def metric_prefix(rate):
    metric_prefixes = {
        "bps": 10**0,
        "kbps": 10**3,
        "mbps": 10**6,
        "gbps": 10**9,
    }
    prefix = {
        rate < 10**3: "bps",
        10**3 < rate < 10**6: "kbps",
        10**6 < rate < 10**9: "mbps",
        rate > 10**9: "gbps",
    }[True]
    return "{:.2f} {}".format(rate / metric_prefixes[prefix], prefix)


def make_progress_bar(completed, total, rate, complete=False):
    # type: (int, int, float, Optional[bool]) -> None
    """
    Prints a progress bar to stdout
    """
    CURSOR.hide_cursor()
    bar_size = 56
    pct_complete = completed / total
    full_bars = int(bar_size * pct_complete)
    try:
        columns = int(subprocess.check_output(['stty', 'size']).decode().split()[1])
    except:
        columns = 80
    progress_bar = (
        "["
        + "#" * full_bars
        + ">"
        + " " * (bar_size - full_bars)
        + "] ({:.2f}%) {}".format(pct_complete * 100, metric_prefix(rate))
    ).ljust(columns)
    print("\r", progress_bar, sep="", end="")
    if complete:
        print()
        CURSOR.show_cursor()


def version_greater_than(ver1, ver2):
    # type: (str, str) -> bool
    """
    Compares semver strings and returns True if the first version is greater
    than the second version.
    """
    for v1, v2 in zip(ver1.split("."), ver2.split(".")):
        if int(v1) > int(v2):
            return True
        elif int(v1) < int(v2):
            return False
    return False


def get_latest(apikey):
    # type: (str) -> Tuple[str, List[str]]
    """
    Returns a tuple with a string representing the latest version found and a
    list of strings of the resources available for that version.
    """
    endpoint = "/products/privatedns/available?latest=true"
    versions = json.loads(authenticated_ns1_request(apikey, endpoint)["body"])
    latest_version = "0.0.0"
    latest_resources = []
    for version in versions["latest_versions"]:
        if version_greater_than(version["version"], latest_version):
            latest_version = version["version"]
            latest_resources = version["resources"]
    return latest_version, latest_resources


def get_all_versions(apikey):
    # type: (str) -> Dict[str, List[str]]
    """
    Returns a dict of string keys (version #) and list of available containers
    """
    endpoint = "/products/privatedns/available"
    versions = json.loads(authenticated_ns1_request(apikey, endpoint)["body"])
    all_versions = {}
    for version in versions["versions"]:
        all_versions[version] = versions["versions"][version]["resources"]
    return all_versions


def get_container(apikey, version, resource):
    # type: (str, str, str) -> str
    """
    Returns download url for requested image
    """
    endpoint = "/products/privatedns?version={}&type=docker&resource={}".format(
        version, resource
    )
    fname = "privatedns_{}:{}".format(resource, version)
    authenticated_ns1_request(apikey, endpoint, file_name=fname)
    return fname


def load_image(file_name):
    # type: (str) -> None
    response = json.loads(unix_socket_request("POST", "/images/load", file_name=file_name))
    if "errorDetail" in response:
        print_stderr(response["errorDetail"].get("message") or response)
    elif "stream" in response:
        print(response["stream"])
    else:
        print("Warning, could not confirm if image loaded")


def main(args):
    # Check if docker is alive
    print_debug("Checking if Docker daemon is responsive")
    if not unix_socket_request("GET", "/containers/json", verbose=False):
        print_stderr("Docker is not running -- please start docker")
        exit(1)
    print_debug("Docker daemon OK")

    print("Determining version availability...")
    if args.version is None:
        version, containers = get_latest(args.key)
    else:
        version = args.version
        all_versions = get_all_versions(args.key)
        if version in all_versions:
            containers = all_versions[version]
        else:
            print_stderr("Specified version does not exist")
            exit(1)

    if args.container is not None:
        containers_available = containers
        containers_requested = [item for sublist in args.container for item in sublist]
        if any([c not in containers_available for c in containers_requested]):
            print_stderr(
                "Specified container not available for this version:",
                ", ".join(
                    [c for c in containers_requested if c not in containers_available]
                ),
            )
            exit(1)
        containers = containers_requested

    if not args.force:
        image_names = [
            "ns1inc/privatedns_{}:{}".format(container, version)
            for container in containers
        ]
        print("This will download:\n", "\n".join(image_names), sep="")
        print("Are you sure you want to continue? [y/N] ", end="")
        sys.stdout.flush()
        accept = sys.stdin.read(1)
        if accept.lower() != "y":
            exit(1)

    for container in containers:
        print("Downloading ns1inc/privatedns_{}:{}".format(container, version))
        fname = get_container(args.key, version, container)
        load_image(fname)
        os.remove(fname)


if __name__ == "__main__":
    help_texts = {
        "main": __doc__,
        "key": "NS1 Managed API key (required for pulling images).",
        "container": "Specify containers to download. Can be specified multiple times.",
        "version": "The version of the docker image to download.",
        "force": "Do not prompt the user for confirmation before downloading.",
        "debug": "Enable debugging for this script.",
    }

    parser = argparse.ArgumentParser(
        description=help_texts["main"], formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument("-k", "--key", type=str, required=True, help=help_texts["key"])

    parser.add_argument(
        "-c",
        "--container",
        type=str,
        action="append",
        nargs="+",
        help=help_texts["container"],
    )

    parser.add_argument(
        "-v", "--version", type=str, help=help_texts["version"],
    )

    parser.add_argument(
        "-f", "--force", action="store_true", help=help_texts["force"],
    )

    parser.add_argument(
        "-d", "--debug", action="store_true", help=help_texts["debug"],
    )

    args = parser.parse_args()

    if args.debug:
        print_debug("Arguments supplied:", args.__dict__)
        DEBUG = True
    
    try:
        main(args)
    except Exception as e:
        if DEBUG:
            print_stderr(e)
        else:
            print_stderr("Something went wrong... run with -d for debug information")
        exit(1)
    except KeyboardInterrupt:
        print("\n")
        sys.stdout.flush()
        print_stderr("Keyboard interrupt, exiting...\n")
    finally:
        CURSOR.show_cursor()
