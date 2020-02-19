variable "docker_image_tag" {
  default     = "2.3.1"
  description = "The image tag of the Docker image. Defaults to the latest GA version number."
}

variable "docker_image_username" {
  default     = "ns1inc"
  description = "The username used in the Docker image name. This should not need to be changed."
}

variable "docker_image_repository" {
  default     = "privatedns_data"
  description = "The repository name used in the Docker image name. This should not need to be changed."
}

variable "docker_registry_address" {
  default     = null
  description = "The absolute URL of the Docker registry (i.e. 'https://registry.hub.docker.com') to pull the container images from.  If not provided, it's assumed the container image is already loaded on the Docker host."
}

variable "docker_registry_username" {
  default     = null
  description = "Username for authentication to Docker registry.  Only required if 'docker_registry_address' is provided."
}

variable "docker_registry_password" {
  default     = null
  description = "Password for authentication to Docker registry.   Only required if 'docker_registry_address' is provided."
}

variable "docker_host" {
  description = "The address of the Docker host to deploy the container on. Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details."
}

variable "docker_network" {
  description = "The name of the Docker network to connect to the container.  Must already exist on the Docker host."
}

variable "container_name" {
  default     = "data"
  description = "The name of the Docker container."
}

variable "pop_id" {
  default     = "mypop"
  description = "Specifies the location (datacenter/pop) of the server where the data container is running"
}

variable "server_id" {
  default     = "myserver"
  description = "Identifies a specific server in a location where the data container is running"
}

variable "data_peers" {
  type        = list(string)
  default     = []
  description = "Identifies the peer(s) of this host's data container with one operating as primary and the other replica."
}

variable "enable_ops_metrics" {
  default     = true
  description = "Whether to enable operational metrics on the container."
}

variable "telegraf_output_elasticsearch_data_host" {
  default     = null
  description = "The elasticsearch host to export metrics"
}

variable "telegraf_output_elasticsearch_index" {
  default     = null
  description = "The elasticsearch index to use when exporting metrics"
}

variable "expose_ops_metrics" {
  default     = true
  description = "Whether to expose operational metrics on the container."
}

variable "primary" {
  default     = true
  description = "Whether the data container will operate as primary in a Primary-Replica configuration."
}


variable "cluster_id" {
  description = "The ID of this data container in the cluster"
  default     = null
}

variable "cluster_size" {
  description = "The size of the cluster, if in cluster mode. Can be either 3 or 5"
  default     = null
}

variable "hostname" {
  default     = "data"
  description = "Hostname to give the running container"
}

variable "docker_log_driver" {
  default     = "json-file"
  description = "Docker log driver to use, see https://docs.docker.com/config/containers/logging/configure/"
}

variable "data_port" {
  default     = 5353
  description = "Port exposed out of the container for data transport.  Setting value to null disables exposing this port."
}
