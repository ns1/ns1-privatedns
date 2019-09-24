# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY NS1 ON A SINGLE DOCKER HOST
# This configuration is not recomended for production.
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY DEDICATED NETWORK ON DOCKER HOST
# A dedicated Docker network should be deployed for the NS1 containers to join.
# -----------------------------------------------------------------------------------------------------------------------
provider "docker" {
  host = var.docker_host
}

resource "docker_network" "host" {
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NS1 CONTAINERS
# This configuration assumes the containers have already been loaded on the Docker host.
# If they have not been loaded, it will attempt to download them from Docker Hub and fail.
# ---------------------------------------------------------------------------------------------------------------------
module "data" {
  source         = "../../modules/data"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
}

module "core" {
  source         = "../../modules/core"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
  bootstrappable = true
}

module "xfr" {
  source         = "../../modules/xfr"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
}

module "dns" {
  source         = "../../modules/dns"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
}

module "dhcp" {
  source         = "../../modules/dhcp"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
}

module "dist" {
  source         = "../../modules/dist"
  docker_host    = var.docker_host
  docker_network = docker_network.host.name
}
