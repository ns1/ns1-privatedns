# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY NS1 ON A TWO DOCKER HOSTS
# This configuration deploys NS1 containers on two hosts.  The Data, Core and XFR containers are deployed togeather on
# the "control" host, while the DHCP, DNS and Dist containers are deployed on the "edge" host.  In a "hub and spoke"
# pattern, "control" can be thought of as the hub, while "edge" would be a sigle spoke.
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY DEDICATED NETWORKS ON DOCKER HOSTS
# A dedicated Docker network should be deployed on both hosts for the NS1 containers to join.
# -----------------------------------------------------------------------------------------------------------------------
provider "docker" {
  alias = "control"
  host  = var.control_host
}

provider "docker" {
  alias = "edge"
  host  = var.edge_host
}

resource "docker_network" "control" {
  provider    = "docker.control"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

resource "docker_network" "edge" {
  provider    = "docker.edge"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONTAINERS ON THE CONTROL HOST
# This configuration assumes the containers have already been loaded on the Docker host.
# If they have not been loaded, it will attempt to download them from Docker Hub and fail.
# ---------------------------------------------------------------------------------------------------------------------
module "data" {
  source         = "../../modules/data"
  docker_host    = var.control_host
  docker_network = docker_network.control.name
}

module "core" {
  source         = "../../modules/core"
  docker_host    = var.control_host
  docker_network = docker_network.control.name
  bootstrappable = true
}

module "xfr" {
  source         = "../../modules/xfr"
  docker_host    = var.control_host
  docker_network = docker_network.control.name
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONTAINERS ON THE EDGE HOST
# The configuration of these modules provides an example of using the moddules with a Docker registry.
# The NS1 Docker containers should already be loaded into the registry at run time and the registry must be reachable 
# from the Docker host.
# ---------------------------------------------------------------------------------------------------------------------
module "dns" {
  source                   = "../../modules/dns"
  docker_host              = var.edge_host
  docker_network           = docker_network.edge.name
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  pop_id                   = "dc2"
  server_id                = "host3"
}

module "dhcp" {
  source                   = "../../modules/dhcp"
  docker_host              = var.edge_host
  docker_network           = docker_network.edge.name
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  pop_id                   = "dc2"
  server_id                = "host3"
}

module "dist" {
  source                   = "../../modules/dist"
  docker_host              = var.edge_host
  docker_network           = docker_network.edge.name
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  # This transforms the user defined URL defined for the control host into
  # a FQDN or IP, which is expected by the `core_hosts` argument
  core_hosts = [element(split("@", var.control_host), 1)]
  pop_id     = "dc2"
  server_id  = "host3"
}
