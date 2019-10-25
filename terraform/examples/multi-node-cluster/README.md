# Multi Node HA Cluster Example

This directory shows an example Terraform configuration that uses all of the [modules](../../modules) to deploy NS1 in a more complex, multi-node pattern with 3 HA Data containers.  This topology provides the foundation of a scalable, hub and spoke topology as well as high availability of the data nodes.  The HA Data nodes are expected to be on 3 separate hosts, labeled `data01`, `data02` and `data03`. The "hub" is refered to in this configuration as the `control01` node and the "spoke" is refered to as the `edge01` node.

In this example, the Docker images have already been loaded on the `control` node's Docker daemon, while the `edge` node will be download the images from a Docker registry.  *Note* that in this example Docker Hub is used as the registry, but this cannot be used in production as the images are not publically available on Docker Hub.

This example will also create dedicated `ns1` Docker networks on all of the `data` Docker hosts as well as the `control` and `edge` Docker hosts.
