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

data "docker_registry_image" "monitoring_edge" {
  count = var.docker_registry_address != null ? 1 : 0
  name  = local.docker_image_name
}

resource "docker_image" "monitoring_edge" {
  count         = var.docker_registry_address != null ? 1 : 0
  name          = data.docker_registry_image.monitoring_edge[count.index].name
  pull_triggers = [data.docker_registry_image.monitoring_edge[count.index].sha256_digest]
  keep_locally  = true
}

resource "docker_volume" "monitoring_edge" {
  name = "ns1monitoring_edge"
}

resource "docker_container" "monitoring_edge" {
  name = "monitoring_edge"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.monitoring_edge[0].latest : local.docker_image_name

  env = [
    # "CONFIG_PORT=3305",
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
    volume_name    = docker_volume.monitoring_edge.name
    container_path = "/ns1/data"
  }


  command = [
    "--pop_id",
    var.pop_id,
    "--server_id",
    var.server_id,
    "--core_host",
    join(",", var.core_hosts),
    "--monitoring_region",
    var.monitoring_region,
    "--digest_service_def_id",
    var.digest_service_def_id,
    "--log_level",
    var.log_level,
    "--metrics_addr_base",
    var.metrics_addr_base,
    "--inst_id",
    var.inst_id,
    "--use_privileged_ping",
    var.use_privileged_ping,
    "--jitter_seconds",
    var.jitter_seconds,
]

  privileged = true
}
