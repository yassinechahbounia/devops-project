#output "db_instance_endpoint" {
 # value = aws_db_instance.mysql.address # Retourne l'hôte sans le port
#}

output "db_instance_endpoint" {
  value = aws_db_instance.mysql.address
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "db_name" {
  value = aws_db_instance.mysql.db_name
}
