terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "docker" {
  host     = "ssh://jbassin@192.168.0.208:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx-test"

  ports {
    internal = 80
    external = 7223
  }
}

resource "null_resource" "provision_server" {
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster.*.id)
  }

  connection {
    type     = "ssh"
    user     = local.user
    password = "sojfadsfsdfsa"
    host     = "dockerarm1.local"
  }

  provisioner "remote-exec" {
    command = "mkdir -p /home/${local.user}/docker"
  }
}
