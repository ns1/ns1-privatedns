# Script for verifying inter-container network connectivity

This script is meant to be used to verify connectivity between containers in a private dns cluster. Specifically it is meant to ensure and validate that connectivity back to the data and/or cache containers is correctly configured.


## Usage
This script must be inserted into a running container to be run from inside the network the container utilizes.

### Examples
Bellow are two examples of how to run this script. However for more detailed information running the script like bellow will provide full help resources:

```shell
$ ./verify_data_connection.sh -h
```

#### Using built in TLS certificates.

```shell
$ docker cp verify_data_connection.sh ${name_or_id_of_container}:/usr/local/bin/

# Verify connectivity back to mongodb in the data container
$ docker exec -it ${name_or_id_of_container} verify_data_connection.sh \
    -s "mongodb"
    -e "${hostname_or_ip_of_data_container}"
    -o "/ns1/data/log/verify_data_connection.sh"
```

#### Using custom TLS certificates.

```shell
$ docker cp verify_data_connection.sh ${name_or_id_of_container}:/usr/local/bin/

# Verify connectivity back to mongodb in the data container
$ docker exec -it ${name_or_id_of_container} verify_data_connection.sh \
    -s "mongodb"
    -z "example.com"
    -e "${hostname_or_ip_of_data_container}"
    -o "/ns1/data/log/verify_data_connection.sh"
```