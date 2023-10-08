resource "docker_image" "ciy_nginx" {
  name = "city-in-yellow-nginx:latest"

  triggers = {
    for filename in fileset(path.module, "../docker/nginx-local/conf/*") :
    filename => filesha1(filename)
  }

  build {
    context = "${path.module}/../docker/nginx-local"
  }
}

resource "docker_container" "ciy_nginx" {
  image   = docker_image.ciy_nginx.image_id
  name    = "ciy-nginx"
  restart = "unless-stopped"
  depends_on = [
    docker_container.infisical_backend,
    docker_container.infisical_frontend
  ]

  networks_advanced {
    name = docker_network.terraform.id
  }

  networks_advanced {
    name = docker_network.infisical.id
  }

  # ports {
  #   internal = 80
  #   external = 80
  # }

  # ports {
  #   internal = 443
  #   external = 443
  # }

  volumes {
    container_path = "/etc/ssl_cert/fullchain.pem"
    host_path      = "/etc/letsencrypt/live/iridium-server.com/fullchain.pem"
    read_only      = true
  }

  volumes {
    container_path = "/etc/ssl_cert/privkey.pem"
    host_path      = "/etc/letsencrypt/live/iridium-server.com/privkey.pem"
    read_only      = true
  }

  volumes {
    container_path = "/etc/ssl_cert/dhparam.pem"
    host_path      = "/etc/ssl/certs/dhparam.pem"
    read_only      = true
  }
}

resource "docker_image" "sslh" {
  name = "sslh:latest"

  triggers = {
    for filename in fileset(path.module, "../vendored/sslh/{Dockerfile,*.c,*.h}") :
    filename => filesha1(filename)
  }

  build {
    context = "${path.module}/../vendored/sslh"
  }
}

resource "docker_container" "ciy_sslh" {
  image   = docker_image.sslh.image_id
  name    = "sslh"
  restart = "unless-stopped"
  depends_on = [
    docker_container.ciy_nginx
  ]

  command = ["--foreground --listen=0.0.0.0:80 --listen=0.0.0.0:443 --tls=ciy-nginx:80 --tls=ciy-nginx:443"]

  networks_advanced {
    name = docker_network.terraform.id
  }

  networks_advanced {
    name = docker_network.host.id
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }
}
