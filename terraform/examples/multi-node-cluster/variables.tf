variable "docker_registry_username" {
  description = "Username for authentication to Docker registry."
}

variable "docker_registry_password" {
  description = "Password for authentication to Docker registry."
}

variable "docker_registry_address" {
  description = "The absolute URL of the Docker registry (i.e. 'https://registry.hub.docker.com') to pull the container images from."
}

variable "docker_image_tag" {
  default     = "2.3.0"
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

variable "docker_protocol" {
  default     = "ssh://"
  description = "The protocol to use when connecting to the docker host"
}

variable "data01_host" {
  description = "The address of the Docker host to deploy the first Data container on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "data02_host" {
  description = "The address of the Docker host to deploy the second Data container on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "data03_host" {
  description = "The address of the Docker host to deploy the third Data container on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "control01_host" {
  description = "The address of the Docker host to deploy the Data, Core and XFR containers on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "edge01_host" {
  description = "The address of the Docker host to deploy the DHCP, DNS and Dist containers on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details"
}

variable "data01_pop_id" {
  description = "The pop id for data01"
  default     = "dc1"
}

variable "data02_pop_id" {
  description = "The pop id for data02"
  default     = "dc1"
}

variable "data03_pop_id" {
  description = "The pop id for data03"
  default     = "dc1"
}

variable "control01_pop_id" {
  description = "The pop id for control01"
  default     = "dc1"
}

variable "edge01_pop_id" {
  description = "The pop id for edge01"
  default     = "dc2"
}

variable "elasticsearch_data_host" {
  default      = null
  description  = "The elasticsearch host to export metrics"
}

variable "elasticsearch_index" {
  default      = null
  description  = "The elasticsearch index to use when exporting metrics"
}

variable "api_fqdn" {
  default     = "api.mycompany.net"
  description = "FQDN to use for the api and feed URLs"
}

variable "portal_fqdn" {
  default     = "portal.mycompany.net"
  description = "FQDN to use for the portal URL"
}

variable "nameservers" {
  default     = "ns1.mycompany.net"
  description = "Nameservers used in SOA records"
}

variable "hostmaster_email" {
  default     = "hostmaster@mycompany.net"
  description = "Hostmaster email address used in SOA records"
}

variable "data01_hostname" {
  default     = "data01"
  description = "Hostmaster email address used in SOA records"
}

variable "data02_hostname" {
  default     = "data02"
  description = "Hostmaster email address used in SOA records"
}

variable "data03_hostname" {
  default     = "data03"
  description = "Hostmaster email address used in SOA records"
}

variable "core_hostname" {
  default     = "core"
  description = "Hostmaster email address used in SOA records"
}

variable "xfr_hostname" {
  default     = "xfr"
  description = "Hostmaster email address used in SOA records"
}

variable "dist_hostname" {
  default     = "dist"
  description = "Hostmaster email address used in SOA records"
}

variable "dns_hostname" {
  default     = "dns"
  description = "Hostmaster email address used in SOA records"
}

variable "dhcp_hostname" {
  default     = "dhcp"
  description = "Hostmaster email address used in SOA records"
}

variable "docker_log_driver" {
  default     = "json-file"
  description = "Docker log driver to use, see https://docs.docker.com/config/containers/logging/configure/"
}
