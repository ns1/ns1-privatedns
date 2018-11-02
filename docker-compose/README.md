# Docker Compose Resources for NS1 Private DNS

These files provide example docker-compose files for setting up and configuring Private DNS container images.

**IMPORTANT NOTE**: After initially starting the container images for the first time with these compose resources, manual changes to container configuration performed via CLI or supd web UI will be overwritten by the values in your compose files if/when containers restart. To prevent this from occurring after initial setup, remove (or comment out) the `command` section from the compose files.

## Requirements

- Docker Version 17.03.x (CE or EE) or higher: https://docs.docker.com/engine/installation/
- Docker Compose Version 1.18.x or higher: https://docs.docker.com/compose/install/.

---

## docker-compose.yml

Use to start all container images on a single host: `data`, `dns`, `web`, `xfr`, and `cache`. Useful for spinning up everything locally to get familiar with the system. 

**IMPORTANT NOTE**: It is not advisable to use this file in production.

#### Variables:

- `TAG`: The image tag, or version number, of the container images; defaults to `1.1.0`
- `POP_ID`: Specifies the location (datacenter/pop) of the server where the data container is running
- `SERVER_ID`: Identifies a specific server in a location where the data container is running

#### For example:

```shell
$sudo TAG=1.1.0 docker-compose -p myproject -f docker-compose.yml up -d
```

---


# Resources for Core and Edge Facilities' Hosts
Production and production-like deployment toplogies generally follow a "hub and spoke" pattern where certain services can be grouped in the "hub" referred to here as `core`; other services on the "spoke", which we referred to as `edge`.

![Example topology with command line variables.](https://github.com/ns1/ns1-privatedns/blob/release/1.1.0/docker-compose/figure1.PNG?raw=true)
**Figure 1**. Example topology with `core-compose.yml` and `edge-compose.yml` command line variables for reference.


## core-compose.yml

Used to start core services on a single host: `data`, `web`, `xfr`.

#### Variables:

- `TAG`: The image tag, or version number, of the container images; defaults to `1.1.0`
- `PRIMARY`: Skip if the host's `data` container will operate as a Replica or set this variable to `true` if the host's `data` container will operate as Primary in a Primary-Replica configuration; defaults to null
- `POP_ID`: Specifies the location (datacenter/pop) of the server where the data container is running; defaults to `mypop` 
- `SERVER_ID`: Identifies a specific server in a location where the data container is running; defaults to `myserver` 
- `DATA_PEERS`: Identifies the peer(s) of this host's data container with one operating as primary and the other replica
- `DATA_HOSTS`: Series of comma delimited hostnames of data containers e.g. data1,data2; defaults to `data`
- `DATA_CONTAINER_NAME`: Sets the container's name; defaults to `data`
- `WEB_CONTAINER_NAME`: Sets the container's name; defaults to `web`
- `XFR_CONTAINER_NAME`: Sets the container's name; defaults to `xfr`
- `API_HOSTNAME`: Hostname for the api and feed URLs; defaults to `localhost`
- `PORTAL_HOSTNAME`: Hostname for the portal; defaults to `localhost`
- `NAMESERVERS`: Nameservers used in SOA records; defaults to `ns1.mycompany.net`
- `HOSTMASTER_EMAIL`: Hostmaster email address for SOA records; defaults to `hostmaster@mycompany.net`

#### For example, starting a core services host with primary data:

```shell
$sudo TAG=1.1.0 POP_ID=nyc SERVER_ID=core1 PRIMARY=true DATA_CONTAINER_NAME=data1 DATA_PEERS=data2 DATA_HOSTS=data1,data2 \ 
docker-compose -p myproject -f core-compose.yml up -d
```

#### For example, starting a core services host with replica data:

```shell
$sudo TAG=1.1.0 POP_ID=nyc SERVER_ID=core2 DATA_CONTAINER_NAME=data2 DATA_PEERS=data1 DATA_HOSTS=data1,data2 \ 
docker-compose -p myproject -f core-compose.yml up -d
```


## edge-compose.yml

Used to start edge services on a single host: `dns` and `cache`.

#### Variables:

- `TAG`: The image tag, or version number, of the container images; defaults to `1.1.0`
- `POP_ID`: Specifies the location (datacenter/pop) of the server where the data container is running; defaults to `mypop` 
- `SERVER_ID`: Identifies a specific server in a location where the data container is running; defaults to `myserver` 
- `DNS_CONTAINER_NAME`: Sets the container's name; defaults to `dns`
- `CACHE_HOSTS`: Series of comma delimited hostnames of cache containers e.g. cache1,cache2; defaults to `cache`
- `DATA_HOSTS`: Series of comma delimited hostnames of data containers e.g. data1,data2; defaults to `data`
- `DNS_OP_MODE`: `authoritative`/`recursive`; the mode of operation for this `dns` container; defaults to `authoritative`
- `CACHE_CONTAINER_NAME`: Sets the container's name; defaults to `cache`

#### For example:

```shell
$sudo TAG=1.1.0 POP_ID=nyc SERVER_ID=edge1 docker-compose -p myproject -f edge-compose.yml up -d
```
