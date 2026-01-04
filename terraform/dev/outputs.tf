output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "ecr_backend_repository_url" {
  value = module.ecr_backend.repository_url
}

output "ecr_frontend_repository_url" {
  value = module.ecr_frontend.repository_url
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

