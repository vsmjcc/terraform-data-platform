# --- SECRETS MANAGER (Armazena o .env) ---
# Cria o segredo para guardar as senhas do Oracle, Shopify e Logins
resource "aws_secretsmanager_secret" "shopify_compare" {
  name        = "shopify-protheus-compare-${var.environment}"
  description = "Variaveis de ambiente da aplicacao de conciliacao Shopify x Protheus"
}

# Nota: A versão do segredo (os valores reais) você deve preencher via Console da AWS ou via CLI 
# para não commitar senhas no git. O JSON deve ter as chaves: 
# DB_USER, DB_PASS, DB_DSN, SHOPIFY_API_KEY, SHOPIFY_PASSWORD, etc.

# --- IAM ROLES (Definição de Confiança) ---
# Permite que o serviço ECS assuma essas roles
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# --- 1. EXECUTION ROLE (Infra: Logs, ECR, Secrets) ---
resource "aws_iam_role" "execution_role" {
  name               = "shopify-protheus-compare-${var.environment}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Anexa a política padrão da AWS para ECS (Logs + ECR)
resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- 2. TASK ROLE (Aplicação: Permissões do código Python) ---
resource "aws_iam_role" "task_role" {
  name               = "shopify-protheus-compare-${var.environment}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# (Opcional) Permite usar o ECS Exec para entrar no container via terminal
resource "aws_iam_role_policy_attachment" "task_role_ssm_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# --- IAM POLICIES (Secrets) ---
# Permite que a task leia o segredo criado acima
data "aws_iam_policy_document" "read_shopify_secret" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.shopify_compare.arn]
  }
}

resource "aws_iam_policy" "read_shopify_secret" {
  name   = "shopify-protheus-compare-${var.environment}-read-secrets"
  policy = data.aws_iam_policy_document.read_shopify_secret.json
}

# Anexa a política à Execution Role que criamos
resource "aws_iam_role_policy_attachment" "shopify_task_secret_read" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.read_shopify_secret.arn
}

# --- SECURITY GROUPS ---
# SG do Load Balancer (Público)
resource "aws_security_group" "shopify_alb" {
  name        = "shopify-protheus-compare-${var.environment}-alb-sg"
  description = "SG for Shopify Compare ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs # Usa a variável definida
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

# SG da Aplicação (Privado - Aceita tráfego apenas do ALB na porta 8501)
resource "aws_security_group" "shopify_app" {
  name        = "shopify-protheus-compare-${var.environment}-app-sg"
  description = "SG for Shopify Compare ECS Task"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from ALB"
    from_port       = 8501 # Porta padrão do Streamlit
    to_port         = 8501
    protocol        = "tcp"
    security_groups = [aws_security_group.shopify_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- LOAD BALANCER ---
resource "aws_lb" "shopify" {
  name               = "shopify-protheus-comp-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shopify_alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "shopify" {
  name        = "shopify-protheus-compare-${var.environment}-tg"
  port        = 8501
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/_stcore/health" # Healthcheck nativo do Streamlit
    protocol            = "HTTP"
    port                = "8501"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

resource "aws_lb_listener" "shopify_https" {
  load_balancer_arn = aws_lb.shopify.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.dns_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shopify.arn
  }
}

# --- ECS TASK DEFINITION ---
resource "aws_ecs_task_definition" "shopify" {
  family                   = "shopify-protheus-compare-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  # Usa as roles locais criadas neste arquivo
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "shopify-compare-app" # Nome consistente com o workflow do Github
      image     = var.app_image
      essential = true

      portMappings = [
        { containerPort = 8501, hostPort = 8501, protocol = "tcp" }
      ],

      # Injeta as variáveis de ambiente lendo do Secrets Manager
      secrets = [
        { name = "DB_USER", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:DB_USER::" },
        { name = "DB_PASS", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:DB_PASS::" },
        { name = "DB_DSN", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:DB_DSN::" },
        { name = "SHOPIFY_API_KEY", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:SHOPIFY_API_KEY::" },
        { name = "SHOPIFY_PASSWORD", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:SHOPIFY_PASSWORD::" },
        { name = "SHOPIFY_SHOP_URL", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:SHOPIFY_SHOP_URL::" },
        { name = "INVOICE_API_URL", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:INVOICE_API_URL::" },
        { name = "APP_USER_ADMIN", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:APP_USER_ADMIN::" },
        { name = "APP_USER_ISA", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:APP_USER_ISA::" },
        { name = "INVOICE_API_USER", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:INVOICE_API_USER::" },
        { name = "INVOICE_API_PASS", valueFrom = "${aws_secretsmanager_secret.shopify_compare.arn}:INVOICE_API_PASS::" }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/shopify-protheus-compare-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "service"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "shopify" {
  name              = "/ecs/shopify-protheus-compare-${var.environment}"
  retention_in_days = 7
}

# --- ECS SERVICE ---
resource "aws_ecs_service" "shopify" {
  name                   = "shopify-protheus-compare-${var.environment}"
  cluster                = var.cluster_name
  launch_type            = "FARGATE"
  desired_count          = 1
  task_definition        = aws_ecs_task_definition.shopify.arn
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.shopify_app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.shopify.arn
    container_name   = "shopify-compare-app"
    container_port   = 8501
  }

  depends_on = [aws_lb_listener.shopify_https]
}

# --- DNS ---
resource "aws_route53_record" "shopify_dns" {
  zone_id = var.dns_zone_id
  name    = "${var.app_name}.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.shopify.dns_name]
}

# Data source auxiliar para pegar o ID da conta
data "aws_caller_identity" "current" {}