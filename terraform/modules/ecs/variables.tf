variable "project" { type = string }
variable "environment" { type = string }

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

# Deux images au lieu d'une seule
variable "backend_image" {
  description = "Image ECR du backend Spring Boot (tag CI_COMMIT_SHA)."
  type        = string
}

variable "frontend_image" {
  description = "Image ECR du frontend Angular (Nginx) (tag CI_COMMIT_SHA)."
  type        = string
}

variable "backend_port" {
  description = "Port du backend Spring Boot."
  type        = number
  default     = 8080
}

variable "frontend_port" {
  description = "Port exposé par Nginx (frontend)."
  type        = number
  default     = 80
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "tags" {
  type    = map(string)
  default = {}
}
