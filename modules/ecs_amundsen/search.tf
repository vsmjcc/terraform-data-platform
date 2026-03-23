# --- SEARCH: Security Group ---
resource "aws_security_group" "search" {
  name        = "amundsen-search-${var.environment}-sg"
  description = "SG for Amundsen Search service"
  vpc_id      = var.vpc_id

  # --- MUDANÇA AQUI ---
  # Permite tráfego na porta 5001 de QUALQUER LUGAR dentro da VPC
  ingress {
    description = "Allow internal traffic from VPC"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # <-- ISSO QUEBRA O CICLO
  }

  # Egress para o Elasticsearch (Porta 9200)
  egress {
    protocol        = "tcp"
    from_port       = 9200
    to_port         = 9200
    security_groups = [var.es_sg_id]
  }

  # --- ADICIONE ESTE BLOCO ---
  # Adiciona a regra de Egress para o Metadata inline
  egress {
    description     = "Allow Search to Metadata"
    from_port       = 5002
    to_port         = 5002
    protocol        = "tcp"
    security_groups = [aws_security_group.metadata.id] # Dependência OK (Metadata não depende de ninguém)
  }

  # Egress Padrão
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "amundsen-search-${var.environment}-sg" }
}


# --- SEARCH: Task Definition ---
resource "aws_ecs_task_definition" "search" {
  family                   = "amundsen-search-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.task_execution.arn # Do main.tf
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "amundsen-search"
      image     = var.image_search
      essential = true

      portMappings = [
        { containerPort = 5001, hostPort = 5001, protocol = "tcp" }
      ],

      environment = [
        # Conexão com Metadata Service
        { name = "METADATA_HOST", value = "${aws_service_discovery_service.metadata.name}.${var.service_discovery_namespace_name}" }, # amundsen-metadata
        { name = "METADATA_PORT", value = "5002" },

        # Conexão com Elasticsearch
        { name = "PROXY_ENDPOINT", value = "http://${var.es_host}:9200" },
        { name = "CREDENTIALS_PROXY_USER", value = "elastic" },
        { name = "PROXY_USER", value = "elastic" }
      ],

      secrets = [
        {
          name      = "CREDENTIALS_PROXY_PASSWORD"
          valueFrom = "${var.es_password_secret_arn}:password::"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/amundsen-search-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "service"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "search" {
  name              = "/ecs/amundsen-search-${var.environment}"
  retention_in_days = 7
}

# --- SEARCH: Service e Service Discovery ---
resource "aws_ecs_service" "search" {
  name                   = "amundsen-search-${var.environment}"
  cluster                = var.cluster_name
  launch_type            = "FARGATE"
  desired_count          = 1
  task_definition        = aws_ecs_task_definition.search.arn
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.search.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.search.arn
  }
}

resource "aws_service_discovery_service" "search" {
  name = "amundsen-search" # amundsen-search.zerezes.local

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