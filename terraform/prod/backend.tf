terraform {
  backend "s3" {
    //bucket       = "bucket-prod-brief3"
    bucket = "bucket-dev-devops-project"
    key          = "prod/terraform.tfstate"
    //region       = "us-east-1"
    region = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
