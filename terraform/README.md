# NS1 Private DNS and Enterprise DDI Module

This repo contains a set of modules in the [modules folder](./modules) for deploying and configuring Private DNS or Enterprise DDI containers.

**Note:** The current location of these modules are for preview purposes only.  At some point these will move to a dedicated repo and will be made available directly via [Terraform Registry](https://registry.terraform.io/).

## Requirements
* Terraform 0.12 or greater
* Docker 17.03.x or greater on each host where the containers will be deployed
* Docker daemons on the hosts where the containers will be deployed must be remotely accessible via SSH or TCP
* Access to the Private DNS or Enterprise DDI container images from the hosts where they will be deployed via private Docker registry or loaded directly to their Docker daemon prior to deployment.

## How to use this Module

* [modules](./modules): This directory contains a standalone module for each container that is used in a Private DNS or Enterprise DDI deployment.
* [examples](./examples): This directory shows examples of different ways to combine the modules in the `modules` directory to deploy Private DNS or Enterprise DDI
* [test](./test): Not yet implemented
* [root directory](.): The root directory contains *an example*  of how to use the modules to deploy Private DNS or Enterprise DDI on a single Docker host. See the [single-node](./single-node) example for the documentation.  This example is great for learning and experimenting, but for production use, please use the underlying modules in the [modules directory](./modules) directly.

To deploy Private DNS or Enterprise DDI in production using this repo:

1. Ensure the NS1 containers are available for use by your Docker hosts.  Note that these are not available via Docker Hub.  There are two methods of making these available supported by these modules:
    - Push the Private DNS or Enterprise DDI images to a private Docker registry, accessible by the Docker hosts where they will be deployed by Terraform.
    - Load the images directly on the Docker hosts where they will be deployed Terraform using the [get_privatedns](https://github.com/ns1/ns1-privatedns/tree/master/utils/get_privatedns) script.

2. Enable the Docker daemon on the Docker hosts where the containers will be deployed for access via TCP or SSH.

3. Use one of the [example](./examples) configs or write your own to deploy the NS1 containers.  Optionally, pass `bootstrappable = true` to the `core` module to enable a helper webserver that bootstraps deployment for ease of use.
