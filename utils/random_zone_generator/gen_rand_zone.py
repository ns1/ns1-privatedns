import random
import string
import requests
import argparse
from typing import List, Union, Tuple


RECORD_TYPES = ("A", "AAAA", "CNAME", "MX", "NS", "TXT")


def get_public_suffixes() -> List[str]:
    suffixes_source = "https://publicsuffix.org/list/public_suffix_list.dat"

    try:
        full_list = requests.get(suffixes_source).text.split("\n")
    except (requests.exceptions.RequestException, requests.ConnectionError):
        suffixes = ["com", "net", "us", "ca", "org"]
        return suffixes

    public_suffixes = set()
    for line in full_list:
        if "END ICANN DOMAINS" in line:
            break
        if not line.startswith("//"):
            ascii_encoded = True
            for char in line:
                if char not in string.ascii_letters + ".":
                    ascii_encoded = False
                    break
            if ascii_encoded:
                public_suffixes.add(line.strip())
    return list(public_suffixes)


SUFFIXES = get_public_suffixes()
ans_type = Union[str, Union[List[str], List[int], List[Union[str, int]]]]


class ZoneFile(object):
    def __init__(
        self,
        name: str,
        mname: str = "ns1.domain.com.",
        rname: str = "hostmaster.domain.com.",
        ttls: List[int] = [1_539_385_040, 43200, 7200, 1_209_600, 3600],
    ) -> None:
        self.origin = name if name.endswith(".") else name + "."
        self.zone_lines: List[str] = []
        self.add_line("", 3600, "SOA", [mname, rname] + ttls)
        self.add_line("", 3600, "A", random_ip())
        for i in range(4):
            self.add_line("", 3600, "NS", ns_answer())

    def add_line(
        self, label: str, ttl: int, rtype: str, answer: ans_type
    ) -> None:
        fqdn = ".".join([label, self.origin]) if label else self.origin

        if isinstance(answer, list):
            answer = " ".join([str(ans) for ans in answer])

        line = f"{fqdn} {ttl} IN {rtype} {answer}"

        self.zone_lines.append(line)

    def to_text(self) -> str:
        zone_file = "\n".join(self.zone_lines).upper()
        zone_file = "".join([char for char in zone_file if ord(char) < 127])
        return zone_file


def gen_record_info(rtype: str) -> Tuple[int, str, ans_type]:
    ttl = random_ttl()
    answer = globals()[f"{rtype.lower()}_answer"]()
    return (ttl, rtype, answer)


def a_answer() -> str:
    return random_ip()


def cname_answer() -> str:
    num_labels = random.randint(1, 2)
    suffix = random.choice(SUFFIXES)
    return (
        ".".join([random_label() for label in range(num_labels)] + [suffix])
        + "."
    )


def txt_answer() -> str:
    num_words = random.randint(5, 20)
    return (
        '"'
        + " ".join(
            [
                random_label(N=random.randint(2, 12)).lower()
                for i in range(num_words)
            ]
        )
        + '"'
    )


def aaaa_answer() -> str:
    return random_ip(protocol=6)


def mx_answer() -> List[Union[int, str]]:
    priority = 10 * random.randint(1, 6)
    server = random_label() + "." + random.choice(SUFFIXES) + "."
    return [priority, server]


def ns_answer() -> str:
    ns = (
        f"ns{random.randint(1, 10)}."
        f"{random_label()}"
        f".{random.choice(SUFFIXES)}."
    )
    return ns


def random_label(N: int = None) -> str:
    if N is None:
        N = random.randint(4, 16)
    return "".join(random.choices(string.ascii_uppercase, k=N))


def random_ip(protocol: int = 4) -> str:
    if protocol == 4:
        ip = ".".join([str(random.randint(0, 255)) for _ in range(4)])
    elif protocol == 6:
        ip = ":".join(
            [
                "".join(random.choices(string.hexdigits, k=4)).lower()
                for i in range(8)
            ]
        )
    return ip


def random_ttl() -> int:
    return random.randint(1, 360) * 60


def gen_zone(zone_name: str, num_records: int) -> str:
    zone = ZoneFile(zone_name)
    for i in range(num_records):
        rtype = random.choice(RECORD_TYPES)
        record = random_label(), *gen_record_info(rtype)
        zone.add_line(*record)
    return zone.to_text()


if __name__ == "__main__":
    help_texts = {
        "main": __doc__,
        "numrecords": ("Number of records the zone should contain"),
        "zone_name": "Name of the zone to be created",
    }

    parser = argparse.ArgumentParser(
        description=help_texts["main"],
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument(
        "-n",
        "--num_records",
        type=int,
        required=True,
        help=help_texts["numrecords"],
    )

    parser.add_argument(
        "-z",
        "--zone_name",
        type=str,
        default="zone.test",
        help=help_texts["zone_name"],
    )

    args = parser.parse_args()
    num_records = args.num_records
    zone_name = args.zone_name

    zone_file = gen_zone(zone_name, num_records)

    print(zone_file)
