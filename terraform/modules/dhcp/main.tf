terraform {
  required_version = ">= 0.12"
}

locals {
  docker_image_name = "${var.docker_image_username}/${var.docker_image_repository}:${var.docker_image_tag}"
}

provider "docker" {
  host = var.docker_host

  # If registry address is provided, configure registry_auth
  dynamic "registry_auth" {
    for_each = var.docker_registry_address != null ? list(var.docker_registry_address) : []
    iterator = address
    content {
      address  = address.value
      username = var.docker_registry_username
      password = var.docker_registry_password
    }
  }
}

data "docker_registry_image" "dhcp" {
  count = var.docker_registry_address != null ? 1 : 0
  name  = local.docker_image_name
}

resource "docker_image" "dhcp" {
  count         = var.docker_registry_address != null ? 1 : 0
  name          = data.docker_registry_image.dhcp[count.index].name
  pull_triggers = [data.docker_registry_image.dhcp[count.index].sha256_digest]
  keep_locally  = true
}

resource "docker_volume" "dhcp" {
  name = "ns1dhcp"
}

resource "docker_container" "dhcp" {
  name = "dhcp"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.dhcp[0].latest : local.docker_image_name

  env = [
    "CONFIG_PORT=3305",
    "CONTAINER_NAME=${var.container_name}",
  ]

  restart = "unless-stopped"

  hostname = var.hostname

  log_driver = var.docker_log_driver

  healthcheck {
    test     = ["CMD", "supd", "health"]
    interval = "15s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    volume_name    = docker_volume.dhcp.name
    container_path = "/ns1/data"
  }


  command = [
    "--pop_id",
    var.pop_id,
    "--server_id",
    var.server_id,
    "--core_host",
    var.dist_or_core_hosts,
    "--enable_ops_metrics",
    var.enable_ops_metrics
  ]

  network_mode = "host"

  privileged = true
}
