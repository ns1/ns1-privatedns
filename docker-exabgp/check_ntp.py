#!/usr/bin/env python3
"""
Usage: check_ntp.py <host> <min_stratum>
$ check_ntp.py pool.ntp.org 3
"""
import sys
import ntplib

def check_health(host, min_stratum=3, port=123, ntp_version=3, timeout=5):
    try:
        c = ntplib.NTPClient()
        resp = c.request(host, port=port, version=ntp_version, timeout=timeout)
    except:
        print("Connection Fail")
        exit(1)
    if (int(resp.stratum) > int(min_stratum)):
        print("Current Stratum: %s, Minimum Stratum: %s" %(resp.stratum, min_stratum))
        exit(2)
    exit(0)


if __name__ == "__main__":
    try:
        host = sys.argv[1]
        min_stratum = sys.argv[2]
    except:
        print("WARNING - healchcheck could not run, please supply host and min_stratum")
        exit(1)
    check_health(host, min_stratum)
