provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "../modules/vpc"

  project     = "devops-project"
  environment = "dev"

  vpc_cidr = "10.10.0.0/16"

  # 2 AZ minimum pour ALB
  azs = ["eu-north-1a", "eu-north-1b"]

  # 2 subnets publics (1 par AZ)
  public_subnet_cidrs = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]

  # 2 subnets privés (1 par AZ)
  private_subnet_cidrs = [
    "10.10.20.0/24",
    "10.10.21.0/24"
  ]

  # DEV: 1 NAT gateway (moins cher)
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
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_image  = var.backend_image
  frontend_image = var.frontend_image

  autoscaling_min        = 1
  autoscaling_max        = 4
  autoscaling_cpu_target = 60
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

module "sqs" {
  source = "../modules/sqs"

  project     = "devops-project"
  environment = "dev"

  lambda_zip_path = var.lambda_zip_path
  tags = {
    Owner = "team-devops"
  }
}
