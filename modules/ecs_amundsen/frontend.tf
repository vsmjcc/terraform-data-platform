# --- FRONTEND: Security Group ---
resource "aws_security_group" "frontend" {
  name        = "amundsen-frontend-${var.environment}-sg"
  description = "SG for Amundsen Frontend service"
  vpc_id      = var.vpc_id

  # --- CORREÇÃO DA PORTA 5002 ---
  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 5000 # <-- DEVE SER 5000 [cite: 37]
    to_port         = 5000 # <-- DEVE SER 5000 [cite: 37]
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb.id]
  }

  # Egress para o Metadata Service (Porta 5002) - OK 
  egress {
    protocol        = "tcp"
    from_port       = 5002
    to_port         = 5002
    security_groups = [aws_security_group.metadata.id]
  }

  # --- CORREÇÃO DA PORTA 5001 ---
  # Egress para o Search Service (Porta 5001) 
  egress {
    protocol        = "tcp"
    from_port       = 5001 # <-- DEVE SER 5001
    to_port         = 5001 # <-- DEVE SER 5001
    security_groups = [aws_security_group.search.id]
  }

  # Egress Padrão [cite: 39]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "amundsen-frontend-${var.environment}-sg" }
}

# --- FRONTEND: Task Definition ---
resource "aws_ecs_task_definition" "frontend" {
  family                   = "amundsen-frontend-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.task_execution.arn # Do main.tf
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  lifecycle {
    create_before_destroy = true
  }


  container_definitions = jsonencode([
    {
      name      = "amundsen-frontend"
      image     = var.image_frontend
      essential = true

      portMappings = [
        { containerPort = 5000, hostPort = 5000, protocol = "tcp" }
      ],

      # Configurações de conexão e OIDC
      environment = [
        # Conexão com Metadata
        { name = "METADATASERVICE_BASE", value = "http://${aws_service_discovery_service.metadata.name}.${var.service_discovery_namespace_name}:5002" },
        #{ name = "METADATASERVICE_REQUEST_PORT", value = "5002" },

        # Conexão com Search
        { name = "SEARCHSERVICE_BASE", value = "http://${aws_service_discovery_service.search.name}.${var.service_discovery_namespace_name}:5001" },
        #{ name = "SEARCHSERVICE_REQUEST_PORT", value = "5001" },

        { name = "OIDC_ENABLED", value = "true" },
        { name = "FRONTEND_SVC_CONFIG_MODULE_CLASS", value = "amundsen_application.oidc_config.OidcConfig" }, # "amundsen_application.config.LocalConfig"

        { name = "FLASK_APP_MODULE_NAME", value = "flaskoidc" },
        { name = "FLASK_APP_CLASS_NAME", value = "FlaskOIDC" },
        { name = "FLASK_OIDC_CONFIG_URL", value = "https://accounts.google.com/.well-known/openid-configuration" },
        { name = "FLASK_OIDC_REDIRECT_URI", value = "/auth" },
        { name = "FLASK_OIDC_FORCE_SCHEME", value = "https" },
        { name = "FLASK_OIDC_SCOPES", value = "openid email profile" },

        { name = "ALLOWED_DOMAIN", value = "zerezes.com.br" },
        { name = "GOOGLE_SA_JSON_PATH", value = "/app/google-sa.json" },
        { name = "REQUEST_SESSION_TIMEOUT_SEC", value = "15" }
      ],


      secrets = [
        {
          name      = "FLASK_OIDC_CLIENT_ID"
          valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:oidc_client_id::"
        },
        {
          name      = "FLASK_OIDC_CLIENT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:oidc_client_secret::"
        },
        {
          name      = "GOOGLE_SA_JSON"
          valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:google_sa_json::"
        },
        {
          name      = "REQUIRED_GROUP"
          valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:required_group::"
        },
        {
          name      = "GOOGLE_ADMIN_SUBJECT"
          valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:google_admin_subject::"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/amundsen-frontend-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "service"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/amundsen-frontend-${var.environment}"
  retention_in_days = 7
}

# --- FRONTEND: Service e Service Discovery ---
resource "aws_ecs_service" "frontend" {
  name                   = "amundsen-frontend-${var.environment}"
  cluster                = var.cluster_name
  launch_type            = "FARGATE"
  desired_count          = 1
  task_definition        = aws_ecs_task_definition.frontend.arn
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids # Roda o serviço nas subnets privadas
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }

  # --- ADIÇÃO AQUI ---
  # [cite_start]Linka o serviço ao Load Balancer [cite: 41]
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "amundsen-frontend"
    container_port   = 5000 # Porta do container do frontend
  }

  depends_on = [aws_lb_listener.frontend_https] # Garante que o listener esteja pronto


}

# Security Group para o ALB do Frontend
resource "aws_security_group" "frontend_alb" {
  name        = "amundsen-frontend-${var.environment}-alb-sg"
  description = "Security group for Amundsen Frontend ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP (for redirect) from anywhere"
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

  tags = {
    Name        = "amundsen-frontend-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# Load Balancer
resource "aws_lb" "frontend" {
  name               = "amundsen-frontend-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb.id]
  subnets            = var.public_subnet_ids
}

# Target Group (Apontando para a porta 5002 do Frontend)
resource "aws_lb_target_group" "frontend" {
  name        = "amundsen-frontend-${var.environment}-tg2"
  port        = 5000 # <- MUDANÇA (Porta do Amundsen Frontend)
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/healthcheck" # <- MUDANÇA (Endpoint de health do Amundsen)
    protocol            = "HTTP"
    port                = "5000" # <- MUDANÇA
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
}

# Listener HTTP (Porta 80) - Redireciona para HTTPS
resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener HTTPS (Porta 443) - Encaminha para o Target Group
resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.dns_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Route53 Record (Ex: amundsen.data.zerezes.com)
resource "aws_route53_record" "frontend_dns" {
  zone_id = var.dns_zone_id
  name    = "catalog.${var.dns_zone_name}" # <- MUDANÇA (nome do subdomínio)
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.frontend.dns_name]
}