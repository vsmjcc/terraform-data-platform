# --- METADATA: Security Group ---
resource "aws_security_group" "metadata" {
  name        = "amundsen-metadata-${var.environment}-sg"
  description = "SG for Amundsen Metadata service"
  vpc_id      = var.vpc_id
  
  # --- MUDANÇA AQUI ---
  # Permite tráfego na porta 5002 de QUALQUER LUGAR dentro da VPC
  ingress {
    description = "Allow internal traffic from VPC"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # <-- ISSO QUEBRA O CICLO
  }

  # Egress para o Neo4j (Porta Bolt 7687)
  egress {
    protocol        = "tcp"
    from_port       = 7687
    to_port         = 7687
    security_groups = [var.neo4j_sg_id]
  }

  # Egress Padrão
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = { Name = "amundsen-metadata-${var.environment}-sg" }
}


# --- METADATA: Task Definition ---
resource "aws_ecs_task_definition" "metadata" {
  family                   = "amundsen-metadata-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.task_execution.arn # Do main.tf
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "amundsen-metadata"
      image     = var.image_metadata
      essential = true
      
      portMappings = [
        { containerPort = 5002, hostPort = 5002, protocol = "tcp" }
      ],

     environment = [
        { name = "PROXY_CLIENT",                   value = "NEO4J" },
        { name = "CREDENTIALS_PROXY_USER",         value = "neo4j" },
        { name = "PROXY_HOST",                     value = "bolt://${var.neo4j_host}" },
        { name = "PROXY_PORT",                     value = "7687" },
        { name = "PROXY_ENCRYPTED",                value = "False" },

        { name = "METADATA_SVC_CONFIG_MODULE_CLASS", value = "metadata_service.metadata_config.MetadataConfig" },

        # OIDC no metadata (validação do Authorization enviado pelo frontend)
        { name = "FLASK_APP_MODULE_NAME",          value = "flaskoidc" },
        { name = "FLASK_APP_CLASS_NAME",           value = "FlaskOIDC" },
        { name = "FLASK_OIDC_CONFIG_URL",          value = "https://accounts.google.com/.well-known/openid-configuration" },
        { name = "FLASK_OIDC_SCOPES",              value = "openid email profile" }
      ]

      secrets = [
        { name = "CREDENTIALS_PROXY_PASSWORD", valueFrom = "${var.neo4j_password_secret_arn}:password::" },
        { name = "FLASK_OIDC_CLIENT_ID",       valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:oidc_client_id::" },
        { name = "FLASK_OIDC_CLIENT_SECRET",   valueFrom = "${aws_secretsmanager_secret.amundsen.arn}:oidc_client_secret::" }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/amundsen-metadata-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "service"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "metadata" {
  name              = "/ecs/amundsen-metadata-${var.environment}"
  retention_in_days = 7
}

# --- METADATA: Service e Service Discovery ---
resource "aws_ecs_service" "metadata" {
  name            = "amundsen-metadata-${var.environment}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.metadata.arn
  enable_execute_command = true  

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.metadata.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.metadata.arn
  }
}

resource "aws_service_discovery_service" "metadata" {
  name = "amundsen-metadata" # Nome DNS será amundsen-metadata.zerezes.local

  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records { 
      type = "A"
      ttl  = 10 
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config { failure_threshold = 1 }
}