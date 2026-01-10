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

variable "lambda_s3_bucket" { 
   type = string 
#   default = "lambda-s3-bucket-devops-brief"
}
variable "lambda_s3_key"    {
  type = string 
  default = "lambda/worker/lambda_nodejs.zip"
}
variable "lambda_source_code_hash" { 
  type = string
  default = null 
  }