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

data "docker_registry_image" "xfr" {
  count = var.docker_registry_address != null ? 1 : 0
  name  = local.docker_image_name
}

resource "docker_image" "xfr" {
  count         = var.docker_registry_address != null ? 1 : 0
  name          = data.docker_registry_image.xfr[0].name
  pull_triggers = [data.docker_registry_image.xfr[0].sha256_digest]
  keep_locally  = true
}

resource "docker_volume" "xfr" {
  name = "ns1xfr"
}

resource "docker_container" "xfr" {
  name = "xfr"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.xfr[0].latest : local.docker_image_name

  env = [
    "CONFIG_PORT=3303",
    "CONTAINER_NAME=${var.container_name}",
  ]

  restart = "unless-stopped"

  log_driver = var.docker_log_driver

  hostname = var.hostname

  # http configuration
  ports {
    internal = 3300
    external = 3303
  }

  # service proxy
  ports {
    internal = 9090
    external = 9093
  }

  # udp zone transfers
  ports {
    internal = 53
    external = 5400
    protocol = "udp"
  }

  # tcp zone transfers
  ports {
    internal = 53
    external = 5400
    protocol = "tcp"
  }

  healthcheck {
    test     = ["CMD", "supd", "health"]
    interval = "15s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    volume_name    = docker_volume.xfr.name
    container_path = "/ns1/data"
  }

  command = [
    "--pop_id",
    var.pop_id,
    "--server_id",
    var.server_id,
    "--core_host",
    join(",", var.core_hosts),
    "--enable_ops_metrics",
    var.enable_ops_metrics
  ]

  networks_advanced {
    name = var.docker_network
  }
}
