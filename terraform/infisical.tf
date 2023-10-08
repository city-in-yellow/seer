locals {
  infisical_env = [
    for name, secret in data.infisical_secrets.infisical.secrets : "${name}=${secret.value}"
  ]
}

module "infisical_backend" {
  source     = "./docker-image"
  docker_tag = "infisical/backend:latest"
}

module "infisical_frontend" {
  source     = "./docker-image"
  docker_tag = "infisical/frontend:latest"
}

module "redis" {
  source     = "./docker-image"
  docker_tag = "redis:7"
}

module "mongo_db" {
  source     = "./docker-image"
  docker_tag = "mongo:jammy"
}

resource "docker_network" "infisical" {
  name   = "infisical"
  driver = "bridge"
}

resource "docker_container" "infisical_backend" {
  image      = module.infisical_backend.id
  name       = "infisical-backend"
  restart    = "unless-stopped"
  depends_on = [docker_container.infisical_mongo]

  env = concat(local.infisical_env, [
    "NODE_ENV=production"
  ])

  networks_advanced {
    name = docker_network.infisical.id
  }
}

resource "docker_container" "infisical_frontend" {
  image      = module.infisical_frontend.id
  name       = "infisical-frontend"
  restart    = "unless-stopped"
  depends_on = [docker_container.infisical_backend]

  env = concat(local.infisical_env, [
    "INFISICAL_TELEMETRY_ENABLED=false"
  ])

  networks_advanced {
    name = docker_network.infisical.id
  }
}

resource "docker_container" "infisical_redis" {
  image   = module.redis.id
  name    = "infisical-dev-redis"
  restart = "unless-stopped"

  env = concat(local.infisical_env, [
    "ALLOW_EMPTY_PASSWORD=yes"
  ])

  networks_advanced {
    name = docker_network.infisical.id
  }

  # ports {
  #   internal = 6379
  #   external = 6379
  # }

  volumes {
    container_path = "/data"
    host_path      = "${local.storage_path}/infisical/redis"
  }
}

resource "docker_container" "infisical_mongo" {
  image   = module.mongo_db.id
  name    = "infisical-mongo"
  restart = "unless-stopped"

  env = local.infisical_env

  networks_advanced {
    name = docker_network.infisical.id
  }

  volumes {
    container_path = "/data/db"
    host_path      = "${local.storage_path}/infisical/mongo"
  }
}

provider "infisical" {
  host          = "https://infisical.iridium-server.com"
  service_token = var.infisical_service_token
}

data "infisical_secrets" "infisical" {
  env_slug    = "env"
  folder_path = "/infisical"
}
