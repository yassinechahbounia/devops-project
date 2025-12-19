terraform {
  backend "s3" {
    bucket       = "bucket-prod-brief3"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
