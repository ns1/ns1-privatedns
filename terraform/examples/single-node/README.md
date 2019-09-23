# Single Node Example

This directory shows an example Terraform configuration that uses all of the [modules](../../modules) to deploy NS1 on a single host.  This is useful for spinning up everything locally to get familiar with the system.

This example assumes the Docker images have already been loaded on the host's Docker daemon.

This example will also create dedicated `ns1` Docker networks on both the `control` and `edge` Docker hosts.

**IMPORTANT NOTE**: It is not advisable to use this configuration in production.
