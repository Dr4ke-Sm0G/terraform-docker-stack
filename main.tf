terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

locals {
  prefix       = "${var.project}-${var.env}"
  network_name = "${local.prefix}-network"
  volume_name  = "${local.prefix}-pgdata"
  db_name      = "${local.prefix}-postgres"
  api_name     = "${local.prefix}-api"
  nginx_name   = "${local.prefix}-nginx"
}

# --- INFRASTRUCTURE (Réseau & Volume) ---

resource "docker_network" "app_net" {
  name = local.network_name
}

resource "docker_volume" "pg_data" {
  name = local.volume_name
}

# --- IMAGES DOCKER ---

resource "docker_image" "postgres" {
  name = var.db_config.image
}

resource "docker_image" "api" {
  name = var.api_config.image
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

# --- CONTENEUR 1 : BASE DE DONNÉES ---

resource "docker_container" "postgres" {
  name  = local.db_name
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=${var.db_config.name}",
    "POSTGRES_USER=${var.db_config.user}",
    "POSTGRES_PASSWORD=${var.db_config.password}"
  ]

  volumes {
    volume_name    = docker_volume.pg_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app_net.name
  }
}

# --- CONTENEUR 2 : API ---

resource "docker_container" "api" {
  name  = local.api_name
  image = docker_image.api.image_id

  # L'API reçoit les infos de connexion vers le conteneur Postgres
  env = [
    "DB_HOST=${local.db_name}",
    "DB_PORT=5432",
    "DB_NAME=${var.db_config.name}",
    "DB_USER=${var.db_config.user}",
    "DB_PASSWORD=${var.db_config.password}"
  ]

  networks_advanced {
    name = docker_network.app_net.name
  }

  depends_on = [docker_container.postgres]
}

# --- CONTENEUR 3 : REVERSE PROXY NGINX ---

resource "docker_container" "nginx" {
  name  = local.nginx_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.host_ports["nginx"]
  }

  # Injection dynamique de la conf générée par templatefile()
  upload {
    file = "/etc/nginx/nginx.conf"
    content = templatefile("${path.module}/nginx.conf.tftpl", {
      api_host = local.api_name
      api_port = var.api_config.internal_port
    })
  }

  networks_advanced {
    name = docker_network.app_net.name
  }

  depends_on = [docker_container.api]
}