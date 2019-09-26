#! /usr/bin/env python3.7
"""
Generates a 2fa token to be used for NS1's portal. To use this tool the 2FA
token must be set as an environment variable named PRIVATE_MFA.

Requires pyotp, to install use pip:
$ pip install pyotp

Usage:
$ ./2fa.py
044262
"""
try:
    from pyotp import totp
    import os

    mfa_key = os.environ["PRIVATE_MFA"]
    totp_gen = totp.TOTP(mfa_key)
    print(totp_gen.now())
except Exception as e:
    import sys
    print("Error", e, file=sys.stderr)
    print(__doc__, file=sys.stderr)
