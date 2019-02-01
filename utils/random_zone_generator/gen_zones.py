"""
CLI tool to generate random zones and upload them to the NS1 platform (either
Managed or Private).

Requirements:
Python 3.6 or greater
Requests (pip install requests)

Usage:
Simply call Python, provide this script as an argument and provide the required
arguments for this script.

For example:
$python3.6 gen_zones.py -k <API KEY> -n 2 -a api.nsone.net
"""
import argparse
import random
import requests
import gen_rand_zone


if __name__ == "__main__":
    help_texts = {
        "main": __doc__,
        "numzones": "Number of zones to be created",
        "api_host": (
            "Address of the API container\n"
            "Defaults to localhost"
        ),
        "api_key": "API key to use",
        "org": (
            "Organization number to add the zones to \n"
            "(required with operator key)"
        ),
        "verify": "Disable SSL verification",
    }

    parser = argparse.ArgumentParser(
        description=help_texts["main"],
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument(
        "-n",
        "--num_zones",
        type=int,
        required=True,
        help=help_texts["numzones"],
    )

    parser.add_argument(
        "-a",
        "--api_host",
        type=str,
        default="localhost",
        help=help_texts["api_host"],
    )

    parser.add_argument(
        "-o", "--org", type=int, default=0, help=help_texts["org"]
    )

    parser.add_argument(
        "-k", "--api_key", type=str, required=True, help=help_texts["api_key"]
    )

    parser.add_argument(
        "-v", "--verify", action="store_false", help=help_texts["verify"]
    )

    args = parser.parse_args()

    num_zones = args.num_zones
    api_host = args.api_host
    api_key = args.api_key
    org = args.org

    if not args.verify:
        from requests.packages.urllib3.exceptions import InsecureRequestWarning
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    if org:
        header = {"X-NSONE-Key": f"{api_key}!{org}"}
    else:
        header = {"X-NSONE-Key": api_key}

    for i in range(num_zones):
        zone_name = f"zone{random.randint(0, 10**7)}.test"
        endpoint = f"https://{api_host}/v1/import/zonefile/{zone_name}"
        num_records = random.randint(1, 150)
        zone_file = gen_rand_zone.gen_zone(zone_name, num_records)

        resp = requests.put(
            endpoint,
            headers=header,
            files={"zonefile": zone_file},
            verify=args.verify,
        )

        print("*" * 120)
        print(f"Generating zone '{zone_name}' - SSL verification: {args.verify} - Status:", resp.status_code)
        if resp.status_code != 200:
            print(resp.text, resp.headers)
        else:
            print("Zone created")
        print("*" * 120)
