terraform {
  required_version = ">= 0.12"
}

locals {
  command_template = <<EOT
--pop_id
${var.pop_id}
--server_id
${var.server_id}
%{if length(var.data_peers) > 0~}
--data_peers
${join(",", var.data_peers)}
%{endif~}   
--expose_ops_metrics
${var.expose_ops_metrics~}
%{if var.telegraf_output_elasticsearch_data_host != null}
--telegraf_output_elasticsearch_data_host
${var.telegraf_output_elasticsearch_data_host~}
%{endif~}
%{if var.telegraf_output_elasticsearch_index != null}
--telegraf_output_elasticsearch_index
${var.telegraf_output_elasticsearch_index~}
%{endif~}
%{if var.cluster_id != null}
--cluster_id
${var.cluster_id~}
%{endif~}
%{if var.cluster_size != null}
--cluster_size
${var.cluster_size~}
%{endif~}
%{if var.cluster_size != null}
--cluster_mode "clustering_on"
${var.cluster_size~}
%{endif~}

EOT

  env_template = <<EOT
CONFIG_PORT=3300
CONTAINER_NAME=${var.container_name~}
%{if var.primary}
DATA_PRIMARY=${var.primary}
%{~endif~}
EOT

  docker_image_name = "${var.docker_image_username}/${var.docker_image_repository}:${var.docker_image_tag}"

  cluster_size_options = [3, 5]
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

data "docker_registry_image" "data" {
  count = var.docker_registry_address != null ? 1 : 0
  name  = local.docker_image_name
}

# resource "null_resource" "is_cluster_size_valid" {
#   count = contains(local.cluster_size_options, var.cluster_size) ? 0 : "invalid" # ERROR: Invalid cluster size, can be either 3 or 5
# }

resource "docker_image" "data" {
  count         = var.docker_registry_address != null ? 1 : 0
  name          = data.docker_registry_image.data[count.index].name
  pull_triggers = [data.docker_registry_image.data[count.index].sha256_digest]
  keep_locally  = true
}

resource "docker_volume" "data" {
  name = "ns1data"
}

resource "docker_container" "data" {
  name = "data"
  # If using registry, use sha of found image, otherwise use name that should be found on docker host
  image = var.docker_registry_address != null ? docker_image.data[0].latest : local.docker_image_name

  env = split("\n", local.env_template)

  restart = "unless-stopped"

  hostname = var.hostname

  log_driver = var.docker_log_driver

  ulimit {
    name = "nproc"
    soft = 65535
    hard = 65535
  }

  ulimit {
    name = "nofile"
    soft = 20000
    hard = 40000
  }

  shm_size = var.shared_memory

  # http configuration
  ports {
    internal = 3300
    external = 3300
  }

  dynamic "ports" {
    for_each = var.cluster_id != null ? list(var.cluster_id) : []
    content {
      internal = 5353
      external = 5353
    }
  }

  # metrics export
  ports {
    internal = 8686
    external = 8686
  }

  # service proxy
  ports {
    internal = 9090
    external = 9090
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
    volume_name    = docker_volume.data.name
    container_path = "/ns1/data"
  }

  command = split("\n", local.command_template)

  networks_advanced {
    name = var.docker_network
  }
}
