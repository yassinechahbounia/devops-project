provider "aws" {
  region = "us-east-1" # Aligné avec votre backend.tf pour éviter l'erreur 403 
}

#################################
# Réseau (VPC)
#################################
module "vpc" {
  source = "../modules/vpc"

  project     = "devops-project"
  environment = "dev"
  vpc_cidr    = "10.10.0.0/16"

  # Zones pour us-east-1 (nécessite 2 AZ pour un Load Balancer) 
  azs = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.10.10.0/24", "10.10.11.0/24"]
  private_subnet_cidrs = ["10.10.20.0/24", "10.10.21.0/24"]

  single_nat_gateway = true # Économique pour le DEV
  tags = { Owner = "team-devops" }
}

#################################
# Conteneurs (ECS)
#################################
module "ecs" {
  source = "../modules/ecs"

  project            = "devops-project"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_image  = var.backend_image
  frontend_image = var.frontend_image

  # --- CRITIQUE : Connexion à la base de données ---
  # Ces variables doivent être déclarées dans modules/ecs/variables.tf
  rds_hostname = module.rds.db_instance_endpoint
  rds_db_name  = "productdb"
  rds_username = "admin"
  rds_password = var.db_password

  autoscaling_min        = 1
  autoscaling_max        = 4
  autoscaling_cpu_target = 60
}

#################################
# Base de données (RDS)
#################################
module "rds" {
  source = "../modules/rds"

  project            = "devops-project"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  db_name     = "productdb"
  db_username = "admin"
  db_password = var.db_password
  
  # Autorise le trafic venant du Security Group d'ECS
  ecs_sg_id = module.ecs.service_sg_id 
}

#################################
# Registres (ECR)
#################################
module "ecr_backend" {
  source = "../modules/ecr"
  name   = "brief3-backend"
  tags   = { Project = "devops-project", Environment = "dev" }
}

module "ecr_frontend" {
  source = "../modules/ecr"
  name   = "brief3-frontend"
  tags   = { Project = "devops-project", Environment = "dev" }
}

#################################
# Messagerie (SQS)
#################################
module "sqs" {
  source = "../modules/sqs"

  project         = "devops-project"
  environment     = "dev"
  lambda_zip_path = var.lambda_zip_path # Assurez-vous que cette variable est dans variables.tf
  tags            = { Owner = "team-devops" }
}