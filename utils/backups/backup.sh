#!/usr/bin/env bash

usage() {
    echo "$(basename $0) <data_container_name> <back up location> <min disk space> <log on success> <filename prefix>"
    exit 1
}

if [ -z "$1" ]; then
  usage
fi

DATA_NAME=$1
BAK_LOC=${2-"./"}
MIN_DISK=${3-"1048576"} # 1kb blocks => 1gb
LOG_SUC=${4-true}
F_PREFIX=${5-""}

sanity_check() {
  # try to fail gracefully if we don't have docker, a good container id, or
  # a container without supd
  if ! docker exec -i "$1" supd --version 2>&1>/dev/null; then
    # run it again without supressing output
    echo sanity check failed:
    docker exec -i "$1" supd --version
    echo exiting
    exit 1
  fi
}

get_cluster_id() {
  docker exec -i "$1" bash <<'EOF'
  supd viewconfig -ay | awk '
    $1=="cluster_mode:"&&$2~/clustering_on/{x++}
    $1=="cluster_id:"&&$2!~/undefined/{y=$2}
    END{if (x) print y}
  '
EOF
}

get_leader_id() {
  docker exec -i "$1" bash <<'EOF'
    stc status | awk '$1$2=="MasterKeeper:"{print substr($3,5)}'
EOF
}

supd_is_primary() {
  if [ "$(docker exec -i "$1" supd primary)" = "this supd is primary" ]; then
    return 0
  else
    return 1
  fi
}

we_are_primary() {
  # check if we are in cluster mode
  cluster_id="$(get_cluster_id $*)"
  if [ "$cluster_id" ]; then
    # we're in cluster mode, check if we are the leader
    leader_id="$(get_leader_id $*)"
    if [ "$leader_id" = "$cluster_id" ]; then
      return 0
    else
      return 1
    fi
  else
    # we're not in cluster mode, check if we are primary
    if supd_is_primary $*; then
      return 0
    else
      return 1
    fi
  fi
}

have_min_disk() {
    # Check if enough disk space remains on host
    # Were checking the root directory which may be inaccurate
    space_left=$(df | awk '$6=="/" {print $4}')
    if [ -z "$space_left" ]; then
      return 0
    fi
    if [ "$(df | awk '$6=="/" {print $4}')" -gt "$MIN_DISK" ]; then
      return 0
    else
      return 1
    fi
}

backup() {
    if have_min_disk; then
        docker exec "$DATA_NAME" supd backup_db > /dev/null
        FNAME="$(docker exec $DATA_NAME ls /ns1/data/backup | grep "\.gz$" | head -n1)"
        FSIZE="$(docker exec $DATA_NAME ls -l /ns1/data/backup/$FNAME | awk '{print $5}')"
        if [ -z "$FNAME" -o -z "$FSIZE" ]; then
           echo "missing FNAME=$FNAME or FSIZE=$FSIZE"
           exit 1
        fi
        docker cp "$DATA_NAME:/ns1/data/backup/$FNAME" "$BAK_LOC/${F_PREFIX}${FNAME}"
        docker exec "$DATA_NAME" sh -c 'ls /ns1/data/backup/archived | xargs -I % rm /ns1/data/backup/archived/%'
        if [ $? -ne 0 ]; then
            echo "ERROR: back up failed"
            exit 1
        else
            if [ "$LOG_SUC" == "true" ]; then
              echo "Back up complete: $BAK_LOC/${F_PREFIX}${FNAME} - ${FSIZE} bytes"
            fi
        fi
    else
        echo "Insufficient disk space remaining"
        exit 1
    fi
}

sanity_check $*

if we_are_primary $*; then
    backup
else
    if [ $LOG_SUC == "true" ]; then
        echo "This node is not primary - not performing backup"
    fi
fi
