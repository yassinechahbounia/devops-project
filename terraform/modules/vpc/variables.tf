variable "project" {
  description = "Nom du projet (utilisé dans les tags et les noms)."
  type        = string
}

variable "environment" {
  description = "Environnement: dev ou prod (sert aux tags et au naming)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC (ex: 10.10.0.0/16)."
  type        = string
}

variable "azs" {
  description = "Liste des AZ utilisées (ex: [\"us-east-1a\",\"us-east-1b\"])."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR des subnets publics (1 par AZ)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs doit avoir la même taille que azs (1 subnet public par AZ)."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR des subnets privés (1 par AZ)."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs doit avoir la même taille que azs (1 subnet privé par AZ)."
  }
}

variable "single_nat_gateway" {
  description = "Si true: 1 NAT pour tout le VPC (moins cher, DEV). Si false: 1 NAT par AZ (plus HA, PROD)."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Active DNS hostnames dans le VPC (utile pour ECS, endpoints, logs)."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Active DNS support dans le VPC."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags additionnels (optionnels)."
  type        = map(string)
  default     = {}
}
