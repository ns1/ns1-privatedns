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

data "docker_registry_image" "dist" {
  count = var.docker_registry_address != null ? 1 : 0
  name  = local.docker_image_name
}

resource "docker_image" "dist" {
  count         = var.docker_registry_address != null ? 1 : 0
  name          = data.docker_registry_image.dist[0].name
  pull_triggers = [data.docker_registry_image.dist[0].sha256_digest]
  keep_locally  = true
}

resource "docker_volume" "dist" {
  name = "ns1dist"
}

resource "docker_container" "dist" {
  name = "dist"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.dist[0].latest : local.docker_image_name

  env = [
    "CONFIG_PORT=3304",
    "CONTAINER_NAME=${var.container_name}",
  ]

  restart = "unless-stopped"

  hostname = var.hostname

  log_driver = var.docker_log_driver

  # http configuration
  ports {
    internal = 3300
    external = 3304
  }

  # data transport
  ports {
    internal = 5353
    external = 5353
    # can we map this to 5353?
    # how do we switch to ephemeral if on same host
    # as core?
  }

  # service proxy
  ports {
    internal = 9090
    external = 9094
  }

  # enable ipv6 for loopback
  sysctls = {
    "net.ipv6.conf.lo.disable_ipv6" = "0"
  }

  healthcheck {
    test     = ["CMD", "supd", "health"]
    interval = "15s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    volume_name    = docker_volume.dist.name
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
