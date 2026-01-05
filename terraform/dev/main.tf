provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"

  project     = "devops-project"
  environment = "dev"

  vpc_cidr = "10.10.0.0/16"

  # 1 seule AZ pour DEV (coût réduit)
  azs = ["us-east-1a"]

  # 1 subnet public /24
  public_subnet_cidrs = [
    "10.10.10.0/24"
  ]

  # 1 subnet privé /24
  private_subnet_cidrs = [
    "10.10.20.0/24"
  ]

  # DEV: 1 NAT gateway (toujours OK, et nécessaire si ECS est en subnet privé)
  single_nat_gateway = true

  tags = {
    Owner = "team-devops"
  }
}

module "ecs" {
  source = "../modules/ecs"

  project     = "devops-project"
  environment = "dev"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_image  = var.backend_image
  frontend_image = var.frontend_image
}

module "ecr_backend" {
  source = "../modules/ecr"
  name   = "brief3-backend"
  tags = {
    Project     = "devops-project"
    Environment = "dev"
  }
}

module "ecr_frontend" {
  source = "../modules/ecr"
  name   = "brief3-frontend"
  tags = {
    Project     = "devops-project"
    Environment = "dev"
  }
}

module "rds" {
  source = "../modules/rds"

  project            = "devops-project"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Variables de l'application
  db_name     = "productdb"
  db_username = "admin"
  db_password = var.db_password # Ajoutez cette variable dans variables.tf
  
  # Lien avec ECS
  ecs_sg_id = module.ecs.service_sg_id # Assurez-vous que votre module ECS exporte son Security Group
}
