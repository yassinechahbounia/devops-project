# Groupe de sous-réseaux pour RDS (doit être dans les subnets privés)
resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-rds-sn-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.project}-${var.environment}-rds-subnet-group" }
}

# Security Group pour RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Allow MySQL traffic from ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id] # Autorise uniquement le service ECS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/11"]
  }
}

# Instance RDS MySQL
resource "aws_db_instance" "mysql" {
  identifier           = "${var.project}-${var.environment}-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  skip_final_snapshot = true # Pour le DEV uniquement
  publicly_accessible = false
}