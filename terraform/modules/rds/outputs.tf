output "db_instance_endpoint" {
  value = aws_db_instance.mysql.address # Retourne l'hôte sans le port
}