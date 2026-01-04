#################################
# Locals
#################################
locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

#################################
# CloudWatch Logs
#################################
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 7
  tags              = local.common_tags
}

#################################
# ECS Cluster
#################################
resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.environment}-cluster"
  tags = local.common_tags
}

#################################
# Security Group
#################################
# SG des tasks ECS (privé) : n'accepte que le trafic venant du SG ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-${var.environment}-ecs-tasks-sg"
  description = "ECS tasks security group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
  ingress {
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  # IMPORTANT: pour un test rapide sans ALB (temporaire).
  # Si vous ajoutez un ALB ensuite, vous remplacerez ça par "ingress depuis SG du ALB".

# SG du Load Balancer (public)
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # (Optionnel plus tard) HTTPS 443 ici si tu ajoutes un certificat ACM
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################################
# IAM Role & Policy (Execution Role)
#################################
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.project}-${var.environment}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#################################
# ECS Task Definition (2 containers)
#################################
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  tags                     = local.common_tags

  # 2 containers: backend + frontend
  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true

      portMappings = [
        {
          containerPort = var.backend_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "backend"
        }
      }
    },
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true

      dependsOn = [
        { containerName = "backend", condition = "START" }
      ]

      portMappings = [
        {
          containerPort = var.frontend_port
          protocol      = "tcp"
        }
      ]

      # Le frontend (nginx) proxy vers le backend dans la même task via localhost
      environment = [
        { name = "BACKEND_URL", value = "http://127.0.0.1:${var.backend_port}" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

#################################
# ECS Service
#################################
resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  tags            = local.common_tags

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }

  depends_on = [aws_lb_listener.http]
}
