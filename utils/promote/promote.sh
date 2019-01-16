#!/bin/bash

# promote.sh
# this is run from a secondary
# takes: -r (remote user) -p (remote primary hostname), -c (supd config api port), -f (compose file path on both, must include "data" service)
# note: secondary server needs to be able to ssh into primary, preferably pw-less for this to work 100%
# note: remote docker-compose *CANNOT HAVE* DATA_PRIMARY environment variable set or this will potentially force split-brain

# iterate through opts to populate vars for rest of script
while getopts "p:c:f:r:" opt; do
  case $opt in
    p)
      echo "primary hostname: $OPTARG" >&2
      PRIMARY_HOSTNAME=$OPTARG
      ;;
    c)
      echo "primary config port: $OPTARG" >&2
      PRIMARY_PORT=$OPTARG
      ;;
    f)
      echo "compose file path: $OPTARG" >&2
      COMPOSE_FILE=$OPTARG
      ;;
    r)
      echo "remote user: $OPTARG" >&2
      REMOTE_USER=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    ?)
      echo "Option -$OPTARG required" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

DATATAINER=_ns1data

function promote_local {
  echo "Promoting local data container to primary" >&2
  docker-compose -f $COMPOSE_FILE exec data supd primary true
  docker-compose -f $COMPOSE_FILE exec data supd restart_in_mem_db
  docker-compose -f $COMPOSE_FILE exec web supd restart_apid
}

# all vars required to work
if [ -z "$PRIMARY_HOSTNAME" ] || [ -z "$PRIMARY_PORT" ] || [ -z "$COMPOSE_FILE" ] || [ -z "$REMOTE_USER" ]; then
  echo "missing -p, -c, -r or -f"
  exit 1
fi

# this chunk is verifying that we're not primary already before we do anything else
primary_output=$(docker-compose -f $COMPOSE_FILE exec data supd primary)
if [[ $primary_output =~ 'this supd is primary' ]]; then
  echo "You cannot promote a primary container to primary" >&2
  exit 1
fi

# see if remote is up, and if it is, see if remote is primary
remote_is_primary=$(curl -ks "https://$PRIMARY_HOSTNAME:$PRIMARY_PORT/primary")

if [[ $remote_is_primary == "true" ]]; then
  # golden path, you are doing promotion against a running primary
  echo "Remote is up and primary: demoting remote to secondary via HTTP" >&2
  curl -ks -X POST "https://$PRIMARY_HOSTNAME:$PRIMARY_PORT/primary/false"
  sleep 10
  promote_local
elif [[ $remote_is_primary == "false" ]]; then
  # this state can only be hit if the remote you think is primary, isn't
  echo "Remote is up, but it is not marked as a primary: exiting without changing any data containers." >&2
  exit 1
else
  # remote data container is down, but maybe host is up:
  #   attempt to use ssh to clean up remote container and volumes
  echo "Remote is down: attempting to clear remote data container volume via SSH" >&2
  VOLUME="$REMOTE_USER$DATATAINER"
  echo "Removing volume $VOLUME" >&2
  ssh -T $REMOTE_USER@$PRIMARY_HOSTNAME bash <<EOF
    docker-compose -f $COMPOSE_FILE stop data
    docker-compose -f $COMPOSE_FILE rm -f data
    docker volume rm $VOLUME
EOF
  if [ $? -eq 0 ]; then
    # all went well, you can continue with promotions
    echo "Remote primary succesfully cleaned up, it will come up as a replica" >&2
    promote_local
  else
    # fail, we have no information about the state of the remote primary
    echo "Remote ssh cleanup failed: the host is likely down or your user cannot ssh to it, you need to get a shell on the remote primary and either ensure it's set to secondary, or remove the ns1data docker volume with:" >&2
    echo "docker-compose stop data && docker-compose rm data && docker volumes rm $REMOTE_USER$DATATAINER" >&2
    exit 1
  fi
fi

echo "Attempting to bring up remote data container as a replica" >&2
ssh -T $REMOTE_USER@$PRIMARY_HOSTNAME <<EOF
  docker-compose -f $COMPOSE_FILE up -d data
EOF
echo "Double check the original remote primary at $PRIMARY_HOSTNAME:$PRIMARY_PORT to ensure it won't be running as a primary" >&2
echo "You will likely need to restart any remote instances of apid so that it can reconnect to the sessions database."
