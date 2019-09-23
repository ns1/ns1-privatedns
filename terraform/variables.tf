variable "docker_host" {
  description = "The address of the Docker host to deploy the container on (i.e. 'ssh://user@remote-host'). Both ssh:// and tcp:// are supported.  See https://www.terraform.io/docs/providers/docker/index.html for more details."
}
