# Script for capturing network traffic between containers

This script can be used to capture network traffic between containers, so that the data can be analyzed in tshark/wireshark to help diagnose problems. The general idea is that you would run this script on problematic hosts and where they should be connecting from. You must run this on both sides of the connection to properly diagnose issues after the fact.


## Usage
This script must be run with `root` priviledges, and should be run from _outside_ of the containers in question.

### Examples
Bellow are two examples of how to run this script. However for more detailed information running the script like bellow will provide full help resources:

```shell
$ ./dump_traffic.sh -h
```

#### Capturing all network traffic between containers

```shell
$ ./dump_traffic.sh -o /var/lib/pcap/host.in.question.pcap
```

#### Capturing specific network traffic using a custom filter

```shell
$ ./dump_traffic.sh -o /var/lib/pcap/filtered.pcap -f "tcp port 5353 and (host 1.2.3.4 or net 2.0.0.0/8)"
```