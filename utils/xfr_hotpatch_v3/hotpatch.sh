#!/bin/bash
set -ex
XFR_ID=$(docker ps -q --filter "name=xfr")

# Make sure we are patching a clean 1.1.1:

xfrd_md5=`docker exec -t $XFR_ID md5sum /ns1-images/xfrd/opt/nsone/xfrd/xfrd.py |awk '{ print $1; }'`
notify_md5=`docker exec -t $XFR_ID md5sum /ns1-images/xfrd/opt/nsone/xfrd/xfr_notify_sender.py | awk '{ print $1; }'`
if [ $xfrd_md5 != "0fbaa34dca0f31f1e0e7ef95248ec30f" ] || [ $notify_md5 != "4ba83d63569748ee811fded401cc4fdd" ]; then
	echo "!!! Unable to continue -- xfr container does not appear to be a clean 1.1.1"
	exit 1
fi

docker cp xfrd-debug.patch $XFR_ID:/bin
docker exec -t $XFR_ID sh -c "patch -d /ns1-images/xfrd/opt/nsone/xfrd -p2 < /bin/xfrd-debug.patch"
docker restart $XFR_ID
