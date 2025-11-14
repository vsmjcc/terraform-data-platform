resource "aws_security_group" "alb" {
  name        = "airflow-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "airflow-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "airflow" {
  name        = "airflow-${var.environment}-ecs-sg"
  description = "Security group for Airflow ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "airflow-${var.environment}-ecs-sg"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "allow_ecs_to_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = var.efs_security_group_id
  source_security_group_id = aws_security_group.airflow.id
}