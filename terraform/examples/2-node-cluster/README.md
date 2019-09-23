# 2 Node Cluster Example

This directory shows an example Terraform configuration that uses all of the [modules](../../modules) to deploy NS1 in a simple, 2 node pattern.  This topology provides the foundation of a scalable, hub and spoke topology.  The "hub" is refered to in this configuration as the `control` node and the "spoke" is refered to as the `edge` node.

In this example, the Docker images have already been loaded on the `control` node's Docker daemon, while the `edge` node will be download the images from a Docker registry.  *Note* that in this example Docker Hub is used as the registry, but this cannot be used in production as the images are not publically available on Docker Hub.

This example will also create dedicated `ns1` Docker networks on both the `control` and `edge` Docker hosts.
