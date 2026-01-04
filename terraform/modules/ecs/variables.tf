# variable "project" { type = string }
# variable "environment" { type = string }

# variable "vpc_id" { type = string }
# variable "private_subnet_ids" { type = list(string) }

# # Deux images au lieu d'une seule
# variable "backend_image" {
#   description = "Image ECR du backend Spring Boot (tag CI_COMMIT_SHA)."
#   type        = string
# }

# variable "frontend_image" {
#   description = "Image ECR du frontend Angular (Nginx) (tag CI_COMMIT_SHA)."
#   type        = string
# }

# variable "backend_port" {
#   description = "Port du backend Spring Boot."
#   type        = number
#   default     = 8080
# }

# variable "frontend_port" {
#   description = "Port exposé par Nginx (frontend)."
#   type        = number
#   default     = 80
# }

# variable "cpu" {
#   type    = number
#   default = 512
# }

# variable "memory" {
#   type    = number
#   default = 1024
# }

# variable "tags" {
#   type    = map(string)
#   default = {}
# }

# ##Ton ALB doit être dans les subnets publics
# variable "public_subnet_ids" {
#   type = list(string)
# }

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_port" {
  type    = number
  default = 8080
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

###AutoScaling
variable "autoscaling_min" {
  type    = number
  default = 1
}

variable "autoscaling_max" {
  type    = number
  default = 3
}

variable "autoscaling_cpu_target" {
  type    = number
  default = 60
}
