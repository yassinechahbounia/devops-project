variable "backend_image" {
  description = "URI ECR backend, ex: <account>.dkr.ecr.us-east-1.amazonaws.com/mini-cicd-backend:<tag>"
  type        = string
}

variable "frontend_image" {
  description = "URI ECR frontend, ex: <account>.dkr.ecr.us-east-1.amazonaws.com/mini-cicd-frontend:<tag>"
  type        = string
}

variable "db_password" { 
  type = string
  sensitive = true 
}
variable "lambda_zip_path" {
  type        = string
  description = "Chemin local du zip Lambda (Node.js)."
}

