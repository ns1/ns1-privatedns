variable "docker_image_tag" {
  default     = "2.5.9"
  description = "The image tag of the Docker image. Defaults to the latest GA version number."
}

variable "docker_image_username" {
  default     = "ns1inc"
  description = "The username used in the Docker image name. This should not need to be changed."
}

variable "docker_image_repository" {
  default     = "privatedns_monitoring_edge"
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
  default     = "monitoring_edge"
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

variable "inst_id" {
  default     = "1"
  description = "Identifies a specific instance of the service"
}

variable "core_hosts" {
  type        = list(string)
  default     = ["core"]
  description = "List of upstream core containers.  If core containers are on same Docker host, container name can be used.  If core containers are on a seperate Docker host, IP or FQDN of host should be used."
}

variable "hostname" {
  default     = "monitoring_edge"
  description = "Hostname to give the running container"
}

variable "docker_log_driver" {
  default     = "json-file"
  description = "Docker log driver to use, see https://docs.docker.com/config/containers/logging/configure/"
}

variable "monitoring_region" {
  default = "lga"
  description = "Monitoring region code of the service definition"
}

variable "digest_service_def_id" {
  default = "3"
  description = "ID of the monitoring service definition for reading the monitoring jobs digest"
}

variable "log_level" {
  default = "info"
  description = "Logs level of monprobed service"
}

variable "metrics_addr_base" {
  default = "unix:///var/run/ns1daemons/"
  description = "Unix socket that monprobed serves metrics over"
}

variable "use_privileged_ping" {
  default = "true"
  description = "Use privileged to create the necessary raw ICMP sockets for ping probes"
}

variable "jitter_seconds" {
  default = "5"
  description = "A probe will take between 0 and jitter_seconds seconds to start running after it is created"
}
