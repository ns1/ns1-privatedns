# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY NS1 eDDI CLUSTER ON MULTIPLE DOCKER HOSTS
# This configuration deploys NS1 containers on two hosts. The Data cluster is deployed on 3 separate hosts.
# The Core and XFR containers are deployed together on the "control" host, while the DHCP, DNS and Dist containers 
# are deployed on the "edge" host.  In a "hub and spoke" pattern, "control" can be thought of as the hub, while "edge"
#  would be a sigle spoke.
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
  alias = "data01"
  host  = "${var.docker_protocol}${var.data01_host}"
}

provider "docker" {
  alias = "data02"
  host  = "${var.docker_protocol}${var.data02_host}"
}

provider "docker" {
  alias = "data03"
  host  = "${var.docker_protocol}${var.data03_host}"
}

provider "docker" {
  alias = "control01"
  host  = "${var.docker_protocol}${var.control01_host}"
}

provider "docker" {
  alias = "edge01"
  host  = "${var.docker_protocol}${var.edge01_host}"
}

resource "docker_network" "data01" {
  provider    = "docker.data01"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

resource "docker_network" "data02" {
  provider    = "docker.data02"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

resource "docker_network" "data03" {
  provider    = "docker.data03"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

resource "docker_network" "control01" {
  provider    = "docker.control01"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

resource "docker_network" "edge01" {
  provider    = "docker.edge01"
  name        = "ns1"
  driver      = "bridge"
  ipam_driver = "default"
  attachable  = true

  ipam_config {
    subnet = "172.18.12.0/24"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONTAINERS ON THE DATA HOSTS
# This configuration assumes the containers have already been loaded on the Docker host.
# If they have not been loaded, it will attempt to download them from Docker Hub and fail.
# ---------------------------------------------------------------------------------------------------------------------

module "data01" {
  source         = "../../modules/data"
  docker_host    = "${var.docker_protocol}${var.data01_host}"
  docker_network = docker_network.data01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_data"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.data01_hostname
  pop_id         = var.data01_pop_id
  server_id      = var.data01_host
  primary        = false
  cluster_id     = 1
  cluster_size   = 3
  data_peers     = [var.data02_host, var.data03_host]
  telegraf_output_elasticsearch_data_host = var.elasticsearch_data_host
  telegraf_output_elasticsearch_index = var.elasticsearch_index
}

module "data02" {
  source         = "../../modules/data"
  docker_host    = "${var.docker_protocol}${var.data02_host}"
  docker_network = docker_network.data02.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_data"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.data02_hostname
  pop_id         = var.data02_pop_id
  server_id      = var.data02_host
  primary        = false
  cluster_id     = 2
  cluster_size   = 3
  data_peers     = [var.data01_host, var.data03_host]
  telegraf_output_elasticsearch_data_host = var.elasticsearch_data_host
  telegraf_output_elasticsearch_index = var.elasticsearch_index
}

module "data03" {
  source         = "../../modules/data"
  docker_host    = "${var.docker_protocol}${var.data03_host}"
  docker_network = docker_network.data03.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_data"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.data03_hostname
  pop_id         = var.data03_pop_id
  server_id      = var.data03_host
  primary        = false
  cluster_id     = 3
  cluster_size   = 3
  data_peers     = [var.data01_host, var.data02_host]
  telegraf_output_elasticsearch_data_host = var.elasticsearch_data_host
  telegraf_output_elasticsearch_index = var.elasticsearch_index
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONTAINERS ON THE CONTROL HOST
# This configuration assumes the containers have already been loaded on the Docker host.
# If they have not been loaded, it will attempt to download them from Docker Hub and fail.
# ---------------------------------------------------------------------------------------------------------------------

module "core" {
  source         = "../../modules/core"
  docker_host    = "${var.docker_protocol}${var.control01_host}"
  docker_network = docker_network.control01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_core"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.core_hostname
  bootstrappable = false
  pop_id         = var.control01_pop_id
  server_id      = var.control01_host
  data_hosts     = [var.data01_host,var.data02_host,var.data03_host]
  api_fqdn = var.api_fqdn
  portal_fqdn = var.portal_fqdn
  nameservers = var.nameservers
  hostmaster_email = var.hostmaster_email
}

module "xfr" {
  source         = "../../modules/xfr"
  docker_host    = "${var.docker_protocol}${var.control01_host}"
  docker_network = docker_network.control01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_xfr"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.xfr_hostname
  pop_id         = var.control01_pop_id
  server_id      = var.control01_host
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONTAINERS ON THE EDGE HOST
# The configuration of these modules provides an example of using the moddules with a Docker registry.
# The NS1 Docker containers should already be loaded into the registry at run time and the registry must be reachable 
# from the Docker host.
# ---------------------------------------------------------------------------------------------------------------------
module "dns" {
  source                   = "../../modules/dns"
  docker_host              = "${var.docker_protocol}${var.edge01_host}"
  docker_network           = docker_network.edge01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_dns"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.dns_hostname
  pop_id                   = var.edge01_pop_id
  server_id                = var.edge01_host
}

module "dhcp" {
  source                   = "../../modules/dhcp"
  docker_host              = "${var.docker_protocol}${var.edge01_host}"
  docker_network           = docker_network.edge01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_dhcp"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.dhcp_hostname
  pop_id                   = var.edge01_pop_id
  server_id                = var.edge01_host
}

module "dist" {
  source                   = "../../modules/dist"
  docker_host              = "${var.docker_protocol}${var.edge01_host}"
  docker_network           = docker_network.edge01.name
  docker_image_username = var.docker_image_username
  docker_image_repository = "${var.docker_image_repository}_dist"
  docker_image_tag = var.docker_image_tag
  docker_registry_address  = var.docker_registry_address
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  docker_log_driver     = var.docker_log_driver
  hostname    = var.dist_hostname
  # This transforms the user defined URL defined for the control host into
  # a FQDN or IP, which is expected by the `core_hosts` argument
  core_hosts = [element(split("@", var.control01_host), 1)]
  pop_id                   = var.edge01_pop_id
  server_id                = var.edge01_host
}
