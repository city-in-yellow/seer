##########
# Provider
##########
provider "docker" {
  host     = "ssh://${local.user}@${var.host}:${var.port}"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]

  registry_auth {
    address       = "registry.iridium-server.com"
    auth_disabled = true
  }
}

##########
# Networks
##########
resource "docker_network" "terraform" {
  name   = "terraform"
  driver = "bridge"
}

resource "docker_network" "terraform" {
  name   = "host"
  driver = "host"
}

########
# Images
########
module "postgres" {
  source     = "./docker-image"
  docker_tag = "postgres:15"
}

###########
# Portainer
###########
module "portainer" {
  source     = "./docker-image"
  docker_tag = "portainer/portainer-ce:latest"
}

resource "docker_container" "portainer" {
  image   = module.portainer.id
  name    = "portainer"
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.terraform.id
  }

  ports {
    internal = 9000
    external = 20100
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  volumes {
    container_path = "/data"
    host_path      = "${local.storage_path}/portainer"
  }
}
