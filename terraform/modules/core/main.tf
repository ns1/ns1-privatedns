terraform {
  required_version = ">= 0.12"
}

locals {
  env_template = <<EOT
CONFIG_PORT=3302
CONTAINER_NAME=${var.container_name~}
%{if var.bootstrappable}
BOOTSTRAPPABLE=${var.bootstrappable}
%{~endif~}
EOT

  docker_image_name = "${var.docker_image_username}/${var.docker_image_repository}:${var.docker_image_tag}"
}

provider "docker" {
  host = var.docker_host

  # If registry address is provided, configure registry_auth
  dynamic "registry_auth" {
    for_each = var.docker_registry_address != null ? list(var.docker_registry_address) : []
    iterator = address
    content {
      address = address.value
      username = var.docker_registry_username
      password = var.docker_registry_password
    }
  }
}

data "docker_registry_image" "core" {
  count = var.docker_registry_address != null ? 1 : 0
  name = local.docker_image_name
}

resource "docker_image" "core" {
  count = var.docker_registry_address != null ? 1 : 0
  name = data.docker_registry_image.core[count.index].name
  pull_triggers = [data.docker_registry_image.core[count.index].sha256_digest]
  keep_locally = true
}

resource "docker_volume" "core" {
  name = "ns1core"
}

resource "docker_container" "core" {
  name = "core"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.core[0].latest : local.docker_image_name

  env = split("\n", local.env_template)

  restart = "unless-stopped"

  hostname = var.hostname

  log_driver = var.docker_log_driver

  # data transport
  ports {
    internal = 5353
    external = 5353
  }

  # http configuration
  ports {
    internal = 3300
    external = 3302
  }

  # service proxy
  ports {
    internal = 9090
    external = 9092
  }

  # https connections to portal or api
  ports {
    internal = 443
    external = 443
  }

  # http connections to portal or api
  ports {
    internal = 80
    external = 80
  }

  healthcheck {
    test = ["CMD", "supd", "health"]
    interval = "15s"
    timeout = "10s"
    retries = 3
  }

  volumes {
    volume_name = docker_volume.core.name
    container_path = "/ns1/data"
  }

  command = [
    "--pop_id",
    var.pop_id,
    "--server_id",
    var.server_id,
    "--data_host",
    join(",", var.data_hosts),
    "--api_hostname",
    var.api_fqdn,
    "--portal_hostname",
    var.portal_fqdn,
    "--nameservers",
    var.nameservers,
    "--hostmaster_email",
    var.hostmaster_email,
    "--enable_ops_metrics",
    var.enable_ops_metrics
  ]

  networks_advanced {
    name = var.docker_network
  }
}
