provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"

  project     = "mini-cicd"
  environment = "dev"

  vpc_cidr = "10.10.0.0/16"

  # us-east-1 a plusieurs AZ; on en prend 2 pour DEV
  azs = ["us-east-1a", "us-east-1b"]

  # 2 subnets publics /24 (un par AZ)
  public_subnet_cidrs = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]

  # 2 subnets privés /24
  private_subnet_cidrs = [
    "10.10.20.0/24",
    "10.10.21.0/24"
  ]

  # DEV: 1 NAT gateway pour tout (réduction coût)
  single_nat_gateway = true

  tags = {
    Owner = "team-devops"
  }
}

module "ecs" {
  source = "../modules/ecs"

  project     = "mini-cicd"
  environment = "dev"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_image  = var.backend_image
  frontend_image = var.frontend_image

  # ports par défaut: 8080 (spring) et 80 (nginx)
}

