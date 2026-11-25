output "nginx_url" {
  description = "URL d'accès à l'application via Nginx"
  value       = "http://localhost:${var.host_ports["nginx"]}"
}

output "postgres_container_name" {
  description = "Nom DNS interne du conteneur Postgres"
  value       = docker_container.postgres.name
}

output "postgres_password" {
  description = "Mot de passe de la base de données"
  value       = var.db_config.password
  sensitive   = true
}