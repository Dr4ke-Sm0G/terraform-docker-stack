variable "project" {
  type        = string
  description = "Nom du projet"
  default     = "stack-app"
}

variable "env" {
  type        = string
  description = "Environnement cible"

  # Règle de validation 1
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "L'environnement doit être dev, staging ou prod."
  }
}

# Type 'object'
variable "db_config" {
  type = object({
    name     = string
    user     = string
    password = string
    image    = string
  })
  description = "Configuration de PostgreSQL"
  sensitive   = true

  # Règle de validation 2
  validation {
    condition     = length(var.db_config.password) >= 8
    error_message = "Le mot de passe Postgres doit faire au moins 8 caractères."
  }
}

# Type 'object' pour l'API
variable "api_config" {
  type = object({
    image         = string
    internal_port = number
  })
  description = "Configuration du conteneur API"
}

# Type 'map' pour les ports exposés sur la machine hôte
variable "host_ports" {
  type        = map(number)
  description = "Ports exposés sur l'hôte par environnement"
}

# Type 'list' pour les labels Docker communs
variable "extra_labels" {
  type        = list(string)
  description = "Liste de tags/labels de suivi"
  default     = ["terraform", "docker-stack"]
}