output "vpc_id" {
  description = "ID du VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Liste des IDs des subnets publics."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Liste des IDs des subnets privés (recommandés pour ECS tasks)."
  value       = [for s in aws_subnet.private : s.id]
}

# Optionnels (debug / usages avancés)
output "public_route_table_id" {
  description = "ID de la route table publique."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs des route tables privées (1 ou N selon config NAT)."
  value       = [for rt in aws_route_table.private : rt.id]
}

output "nat_gateway_ids" {
  description = "IDs des NAT Gateways."
  value       = [for nat in aws_nat_gateway.this : nat.id]
}
