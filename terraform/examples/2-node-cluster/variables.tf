variable "docker_registry_username" {
  description = "Username for authentication to Docker registry."
}

variable "docker_registry_password" {
  description = "Password for authentication to Docker registry."
}

variable "docker_registry_address" {
  description = "The absolute URL of the Docker registry (i.e. 'https://registry.hub.docker.com') to pull the container images from."
}

variable "control_host" {
  description = "The address of the Docker host to deploy the Data, Core and XFR containers on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "edge_host" {
  description = "The address of the Docker host to deploy the DHCP, DNS and Dist containers on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}
