# Provider
provider "docker" {
  host     = "ssh://${local.user}@${var.host}:${var.port}"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Images
data "docker_registry_image" "postgres" {
  name = "postgres:15"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
}

# Containers
resource "docker_container" "terraform_backend" {
  image   = docker_image.postgres.image_id
  name    = "terraform_backend"
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=seer",
    "POSTGRES_DB=terraform_backend",
    "POSTGRES_PASSWORD=${var.tf_backend_password}"
  ]

  ports {
    internal = 5432
    external = var.tf_backend_port
  }

  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "${local.storage_path}/terraform_backend"
  }
}
