terraform {
  backend "s3" {
    //bucket       = "bucket-dev-brief3"
    bucket = "bucket-dev-devops-project"
    key    = "dev/terraform.tfstate"
    region = "eu-north-1"
    //region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
