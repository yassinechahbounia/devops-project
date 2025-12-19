provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"

  project     = "mini-cicd"
  environment = "prod"

  vpc_cidr = "10.20.0.0/16"

  # PROD: 3 AZ (meilleure résilience)
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs = [
    "10.20.10.0/24",
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]

  private_subnet_cidrs = [
    "10.20.20.0/24",
    "10.20.21.0/24",
    "10.20.22.0/24"
  ]

  # PROD: NAT par AZ (HA, pas de SPOF)
  single_nat_gateway = false

  tags = {
    Owner = "team-devops"
  }
}
