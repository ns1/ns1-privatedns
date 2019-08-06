# xfr private (RFC1918) space fix
## problem:
the xfrd server by default does not allow notifies to be sent to any secondary servers
in private ip ranges.  additionally, a missing configuration option in xfrd.ini was
preventing any notifies from being sent.

## solution:
- patch the xfr daemon to no longer block private ip addresses.
- update ansible playbook to add outbound\_network\_interface to xfrd.ini

## usage
- copy hotpatch.sh and the patch file to the host os. make sure they are both in the same directory.
- `chmod +x hotpatch.sh`
- `./hotpatch.sh`
