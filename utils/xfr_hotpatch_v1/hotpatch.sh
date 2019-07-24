set -ex
XFR_ID=$(docker ps -q --filter "name=xfr")
echo '#!/bin/bash
sed -i "/zone_load_frequency = */c\zone_load_frequency = $1" /ns1/data/etc/xfrd/xfrd.ini 
sed -i "/zone_load_frequency = */c\zone_load_frequency = $1" /ansible/playbooks/roles/ns1_ini/templates/sections/xfrd.ini.j2' > ./tmppatch.sh

docker cp ./tmppatch.sh $XFR_ID:/bin/hotpatch.sh
docker exec $XFR_ID chmod +x /bin/hotpatch.sh
docker exec -t $XFR_ID /bin/hotpatch.sh $1
docker exec -t $XFR_ID supd restart xfrd
