########################################
# MÓDULO ECS - MOCKS (FARGATE + ALB)
########################################

# --- IAM ASSUME ROLE ---
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# --- EXECUTION ROLE ---
resource "aws_iam_role" "execution_role" {
  name               = "${var.app_name}-${var.environment}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- TASK ROLE ---
resource "aws_iam_role" "task_role" {
  name               = "${var.app_name}-${var.environment}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# (Opcional) permitir ECS Exec / SSM (se quiser debugar dentro do container)
resource "aws_iam_role_policy_attachment" "task_role_ssm_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- SECURITY GROUPS ---

# SG do Load Balancer (público)
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "SG for ${var.app_name} ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description = "HTTP Redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG da aplicação (privado - recebe só do ALB)
resource "aws_security_group" "app" {
  name        = "${var.app_name}-${var.environment}-app-sg"
  description = "SG for ${var.app_name} ECS Task"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- LOAD BALANCER + LISTENER ---

resource "aws_lb" "this" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-${var.environment}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = var.app_port
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200,404"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.dns_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# --- LOGS ---

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.app_name}-${var.environment}"
  retention_in_days = 7
}

# --- ECS TASK DEFINITION ---

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      # ⚠️ Nome fixo pra bater com o workflow GitHub (CONTAINER_NAME=mocks-app)
      name      = "mocks-app"
      image     = var.app_image
      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      # Se quiser variáveis de ambiente simples (sem secrets), coloca aqui:
      environment = var.app_environment

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "service"
        }
      }
    }
  ])
}

# --- ECS SERVICE ---

resource "aws_ecs_service" "this" {
  # ⚠️ Nome do serviço pra bater com o workflow (SERVICE_NAME = mocks-${env})
  name                  = "${var.app_name}-${var.environment}"
  cluster               = var.cluster_name
  launch_type           = "FARGATE"
  desired_count         = 1
  task_definition       = aws_ecs_task_definition.this.arn
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "mocks-app"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.https]
}

# --- DNS ---

resource "aws_route53_record" "dns" {
  zone_id = var.dns_zone_id
  name    = "${var.app_name}.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this.dns_name]
}

data "aws_caller_identity" "current" {}
