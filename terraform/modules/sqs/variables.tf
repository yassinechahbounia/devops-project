variable "project" {
    type = string
    }
variable "environment" {
    type = string
    }
variable "tags" { 
    type = map(string) 
    default = {} 
    }

variable "lambda_zip_path" {
  type        = string
  description = "Chemin vers le zip de la Lambda (ex: lambda.zip ou chemin relatif)."
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "batch_size" {
  type    = number
  default = 10
}

variable "max_receive_count" {
  type    = number
  default = 5
}

# variable "lambda_s3_bucket" {
#   type = string 
# }
variable "lambda_s3_key"    { 
type = string 
}