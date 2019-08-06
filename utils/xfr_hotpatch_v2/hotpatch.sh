#!/bin/bash
set -ex
XFR_ID=$(docker ps -q --filter "name=xfr")

docker cp fix-notify-private-1.1.1.patch $XFR_ID:/bin
docker exec -t $XFR_ID sh -c "patch -d /ns1-images/xfrd/opt/nsone/xfrd -p2 < /bin/fix-notify-private-1.1.1.patch"
docker exec -t $XFR_ID sh -c "echo \"outbound_network_interface = 0.0.0.0\" >> /ansible/playbooks/roles/ns1_ini/templates/sections/xfrd.ini.j2"
docker restart $XFR_ID
