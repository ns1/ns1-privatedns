# promote.sh
this is a utility script to be run from a secondary data container to attempt to demote the current primary data container. If it cannot communicate with the host running the current primary, it will fail and you will have to manually demote the current primary and promote the desired secondary. THIS SCRIPT CAN BE DESTRUCTIVE: in the case that the secondary host can communicate with the primary host via SSH, but the primary data container is down, the secondary host will SSH into the primary host and destroy the stale/damaged primary data container and remove it's volume, then bring bring up a fresh data container. It is absolutely crucial that you do not have a "restart" stanza in the data container portion of the docker-compose file, anywhere. You also need to avoid using the DATA_PRIMARY environment variable in the compose files: if it is set to true, the fresh data container will come up as a primary which will force a dual-primary/splitbrain scenario.

## requirements
- all data nodes need to allow ssh connections to each other
- all data nodes need to have a docker-compose file at the same path
- all data nodes need to use the same user
- the user needs to be able to run docker-compose commands
- the script must be run from a host running a secondary data container
- the primary data container must be reachable via hostname from the secondary container

## parameters
- `-p`: hostname of primary data node
- `-c`: port of config management interface on primary data node
- `-f`: path to compose file on all hosts
- `-r`: user with docker/compose permissions on all hosts

## order of operations
1. ensure that local data container is secondary
2. attempt to communicate via remote primary via http. If it is primary and is present, demote via http, wait 10 seconds, then promote locally via docker-compose command.
3. attempt to use ssh to destroy broken/stopped primary data container and volume on the remote host. THIS IS REQUIRED IF YOU HAD A NODE RESTART AND THE DATA CONTAINER IS MARKED AS PRIMARY.
4. promote local to primary
5. bring up empty data container on remote host as secondary

