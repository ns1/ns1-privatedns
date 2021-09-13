#!/usr/bin/env python3
"""
Usage: python3 check_ddi.py <host> <port> <user> <password>
$ python3 check_ddi.py 192.168.56.2 3300
"""
import logging
import sys
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import json


def check_health(session, host, port, user="ns1", pw="private"):
    endpoint = "https://" + host + ":" + port + "/checks"
    try:
        resp = session.get(endpoint, timeout=2).json()
    except:
        exit(1)
    if any(resp.values()):
        resp = {k:v for k,v in resp.items() if v}
        exit(2)
    exit(0)


if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    session = requests.Session()
    try:
        host = sys.argv[1]
        port = sys.argv[2]
    except:
        print("WARNING - healchcheck could not run, please supply host and port")
        exit(1)
    try:
        USER = sys.argv[3]
        PW = sys.argv[4]
    except:
        USER = "ns1"
        PW = "private"
    session.auth = (USER, PW)
    session.verify = False
    check_health(session, host, port, USER, PW)
