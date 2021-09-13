# docker-exabgp

This is a fork of the excellent exabgp container created by Mike Nowak. Thanks Mike!

https://github.com/mikenowak/docker-exabgp

Modifications include...
 - Update Alpine base, exabgp version, and dependencies
 - Adjustments to the sample exabgp.conf file to support compatibility with Ubiquiti EdgeRouter devices
 - Inclusion of a script to check the health of an NS1 DDI DNS container
 - Inclusion of a script to check exabgp health and report it to Docker

The container works with `NET_ADMIN` capabilities and `net=host` to automatically add loopback IP addresses to the host O/S.  The necessary routes for the created loopbacks are then advertised to neighbours.

# Prerequisites

 - This document assumes an existing NS1 DDI environment is deployed and operating normally.  All steps below should be performed on one or more of your edge hosts (i.e. the servers that host the `dns` containers)

 - Configuration of Anycast is very dependent on your network design and configuration.  Contact your network administrator(s) to assist.  You will at minimum need to know peer IP, remote AS, and local AS.  You will also need to know what IP to use for Anycast - it should _not_ exist on the host system.

 - Your DDI DNS container must have port 3300 (container configuration API) exposed as port 3301 on the host.  This should already be the case unless you've modified the default docker-compose files to remove this port mapping.

# Installation and Configuration

1) Download a copy of exabgp.conf.example and place it somewhere on the host system (i.e. /root/exabgp.conf).  Edit it and make the following adjustments:

 - Change neighbor IP, router-id, local-as, and peer-as as needed. Router ID is typically the primary IP address of the host system.  

 - If other configuration variables are necessary (multihop, authentication, etc), consult the exabgp documentation and add additional lines to the neighbor configuration section as needed.

 - Change the IP address after `--ip` in the `run` line under the watch-dns section.  This should be set to the Anycast IP address you wish to advertise.  This IP address will be automatically added as a loopback IP on the host system and will be advertised in BGP announcements.  

 - If you have the DNS container's API port exposed as something other than port 3301, change the 3301 in the `run` line to the appropriate port.

 2) Add the following to the `services:` section of your `edge-compose.yml` file:

 ```
  anycast:
    image: mwhitted4u/exabgp:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"
    restart: unless-stopped
    stop_grace_period: 30s
    healthcheck:
      test: /usr/local/bin/health.sh
      interval: 15s
      timeout: 10s
      start_period: 120s
    network_mode: host
    cap_add:
      - NET_ADMIN
    volumes:
      - type: bind
        source: /root/exabgp.conf
        target: /usr/etc/exabgp/exabgp.conf
```

3) The anycast service can now be started in the same manner you would use to start the rest of the DDI services:

```docker-compose -p ddi -f edge-compose.yml up -d```

If you're using a different project name than `ddi`, change the value accordingly.

# NTP healthchecks

It's sometimes customary for organizations to run NTP services from the same hosts providing DNS.  An NTP health check script has been added to the container to support anycasting of NTP on a separate IP address.  The container does not provide NTP service itself - one must run NTP service on the host, or in a separate container.

The NTP health check is fairly simplistic - it queries the NTP service, ensures there is a response, and compares the reported stratum with a defined minimum stratum.  The BGP service will advertise routes as long as the NTP services is reachable and the stratum is equal to or higher than the defined minimum (default 2 in the example below).

To add NTP health checks / anycast, add the following section to your `exabgp.conf` file:

```
process watch-ntp {
        encoder text;
        run python -m exabgp healthcheck --cmd "/usr/local/bin/check_ntp.py localhost 2" --no-syslog --label ntp --withdraw-on-down --ip 10.4.1.11/32;
```

Change the `2` in the healthcheck command to your desired minimum stratum.  This value should be equal to the stratum expected of the local NTP service.  For example, if the locally configured NTP service is referencing stratum 1 servers, the local service would be stratum 2, and the health check should be configured for a minimum stratum of 2.  The BGP service will remove announcements for the defined anycast IP if the stratum is outside the minimum (typical if the local service looses sync to its peers), or if the NTP service doesn't respond.

# Verification and Troubleshooting

Once the anycast service is running, use the following command to verify that healthchecks are passing and announcements are being sent:

```
$ docker logs ddi_anycast_1
...
16:55:03 | 15     | api             | route added to neighbor 10.4.100.1 local-ip None local-as 65042 peer-as 65001 router-id 10.4.100.3 family-allowed in-open : 10.4.1.10/32 next-hop self med 100
16:55:08 | 15     | api             | route added to neighbor 10.4.100.1 local-ip None local-as 65042 peer-as 65001 router-id 10.4.100.3 family-allowed in-open : 10.4.1.10/32 next-hop self med 100
...
```

Note that the logs indicate routes being added.  If you instead see logs showing routes being removed, the healthcheck is failing.  Confirm that the DNS container is running, the correct API port (usually 3301) is exposed, and that the DNS container is reporting `healthy`.

To confirm that exabgp has successfully peered with its neighbors, run the following command:
```
$ docker exec ddi_anycast_1 exabgpcli show neighbor summary
Peer            AS        up/down state       |     #sent     #recvd
10.4.100.1      65001     9:29:24 established           4          0
```

In the above example, exabgp has one active session.  A state of _established_ indicates a successful peering.  Note that you can replace _summary_ in the command with _extensive_ for detailed information about each peer.
