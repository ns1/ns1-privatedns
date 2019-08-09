# add additional debugging to xfr notify logic
## problem:
the xfr container applies several iterations of logic to determine if a notify should
be sent.  however, no logging is performed, which makes troubleshooting difficult.  

## solution: 
this patch adds additional logging to the notify process, allowing us to 
troubleshoot situations where notifies are not sent.

## usage
**note:** this patch must be applied against a clean xfr container running
the 1.1.1 tag.  the patch will fail cleanly and make no changes if it detects
the xfr container has previous patches or modifications applied.  to undo any
past changes, do the following (adjusted as appropriate for your environment, replacing privatedns with your project name):

- stop and remove the xfr container

  `docker stop privatedns_xfr_1`
  `docker image rm privatedns_xfr_1`

- remove the xfr volume

  `docker rm privatedns_ns1xfr`

- use docker-compose to bring up a fresh xfr container

  `TAG=1.1.1 docker-compose -p privatedns up -d`

once a clean xfr container is running, the patch can be applied as follows:

- copy hotpatch.sh and the patch file to the host os. make sure they are both in the same directory.
- `chmod +x hotpatch.sh`
- `./hotpatch.sh`
