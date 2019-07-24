# xfr propagation delay hotpatch
## problem:
the xfrd server has a configuration option 'zone_load_frequency' that determines
how often xfrd queries the database for the primary zones. Usually, apid
updates it with inbounds, but zone creation can take upwards of 5 minutes
with the default settings here

## solution:
this hotpatch edits the configured value in 2 places inside the xfr container
and restarts the xfrdaemon to respect the new settings

## usage
- copy hotpatch.sh to the host os. 
- `chmod +x hotpatch.sh`
- `./hotpatch.sh <new interval, probably 10-20s for a small/medium deployment is ideal>`
