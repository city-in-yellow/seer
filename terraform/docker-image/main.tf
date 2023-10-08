terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0"
    }
  }
}

variable "docker_tag" {
  type        = string
  description = "the name and tag of the docker image"
}

data "docker_registry_image" "image" {
  name = var.docker_tag
}

resource "docker_image" "image" {
  name          = data.docker_registry_image.image.name
  pull_triggers = [data.docker_registry_image.image.sha256_digest]
}

output "id" {
  value = docker_image.image.image_id
}
