variable "project" { type = string }
variable "environment" { type = string }

variable "create_tfstate_bucket" {
  description = "Créer bucket tfstate (souvent bootstrap manuel, mais possible ici si vous voulez)."
  type        = bool
  default     = false
}

variable "tfstate_bucket_name" {
  type        = string
  default     = null
}

variable "artifacts_bucket_name" {
  description = "Bucket pour artefacts (plans, logs, configs)."
  type        = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
#