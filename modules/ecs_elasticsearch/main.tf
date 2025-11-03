# --- Bloco de Geração de Senha (Padrão adaptado) ---
resource "random_password" "es_password" {
  length  = 16
  special = true
  override_special = "_!#$%^&*()-"
}

resource "aws_secretsmanager_secret" "es_password" {
  name = "${var.name}-${var.environment}-es-password"
}

resource "aws_secretsmanager_secret_version" "es_password_version" {
  secret_id     = aws_secretsmanager_secret.es_password.id
  secret_string = jsonencode({
    username = "elastic" # Usuário padrão do Elasticsearch
    password = random_password.es_password.result
  })
}

# --- Bloco IAM (Idêntico ao Neo4j) ---
resource "aws_iam_role" "task_execution" {
  name = "${var.name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Bloco EFS (Adaptado para Elasticsearch) ---

resource "aws_security_group" "efs" {
  name        = "${var.name}-efs-${var.environment}-sg"
  description = "Security group for Elasticsearch EFS"
  vpc_id      = var.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.name}-efs-${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_efs_file_system" "es_data" {
  creation_token = "${var.name}-data-${var.environment}"
  tags = {
    Name        = "${var.name}-data-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "es_data" {
  for_each          = toset(var.private_subnet_ids) 
  file_system_id    = aws_efs_file_system.es_data.id
  subnet_id         = each.value
  security_groups   = [aws_security_group.efs.id]
}

# Ponto de Acesso EFS (Note as mudanças de UID/GID e Path)
resource "aws_efs_access_point" "es_data" {
  file_system_id = aws_efs_file_system.es_data.id
  
  root_directory {
    path = "/usr/share/elasticsearch/data" # <-- MUDANÇA: Caminho do ES
    creation_info {
      owner_gid   = 1000 # <-- MUDANÇA: UID/GID do ES
      owner_uid   = 1000 # <-- MUDANÇA: UID/GID do ES
      permissions = "0755"
    }
  }
  posix_user {
    gid = 1000 # <-- MUDANÇA: UID/GID do ES
    uid = 1000 # <-- MUDANÇA: UID/GID do ES
  }
}

# --- Bloco Elasticsearch (Baseado no Neo4j) ---

resource "aws_security_group" "elasticsearch" {
  name        = "${var.name}-${var.environment}-sg"
  description = "Security group for Elasticsearch Fargate"
  vpc_id      = var.vpc_id
  
  # Regra de Egress para o EFS (Igual ao Neo4j)
  egress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.efs.id]
  }

  # Regra de Egress Padrão (Igual ao Neo4j)
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-${var.environment}-sg"
    Environment = var.environment
  }
}

# --- REGRAS DE SECURITY GROUP SEPARADAS ---

# Regra 1: Permite EFS (Ingress) receber do ES (Igual ao Neo4j)
resource "aws_security_group_rule" "allow_es_to_efs" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049 # NFS
  to_port                  = 2049
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.elasticsearch.id
  description              = "Allow Elasticsearch to access EFS"
}

# Regra 2: Permite Aplicações (Amundsen) acessarem o ES
resource "aws_security_group_rule" "allow_api_access" {
  count             = length(var.allowed_security_groups) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 9200 # <-- MUDANÇA: Porta do ES
  to_port           = 9200 # <-- MUDANÇA: Porta do ES
  protocol          = "tcp"
  security_group_id = aws_security_group.elasticsearch.id
  source_security_group_id = var.allowed_security_groups[count.index]
}

# --- FIM DAS REGRAS ---

resource "aws_ecs_task_definition" "elasticsearch" {
  family                   = "${var.name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu    # <-- MUDANÇA
  memory                   = var.task_memory # <-- MUDANÇA
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn

  # Volume EFS (Apontando para os recursos do ES)
  volume {
    name = "es-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.es_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.es_data.id
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "elasticsearch"
      image     = var.image
      essential = true
      
      portMappings = [
        {
          containerPort = 9200 # <-- MUDANÇA
          hostPort      = 9200 # <-- MUDANÇA
          protocol      = "tcp"
        }
      ],

      mountPoints = [
        {
          sourceVolume  = "es-data"
          containerPath = "/usr/share/elasticsearch/data" # <-- MUDANÇA
          readOnly      = false
        }
      ],

      # --- MUDANÇA CRÍTICA: Variáveis de Ambiente do ES ---
      environment = [
        {
          name  = "discovery.type"
          value = "single-node" # Essencial para rodar 1 nó
        },
        {
          name  = "xpack.security.enabled"
          value = "true"
        },
        {
          name  = "ELASTIC_PASSWORD"
          value = random_password.es_password.result
        },
        {
          name = "ES_JAVA_OPTS"
          value = var.es_java_opts # Ex: "-Xms1g -Xmx1g"
        }
      ],
      # --- FIM DA MUDANÇA ---

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name}-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])
}

# CloudWatch (Padrão adaptado)
resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = "/ecs/${var.name}-${var.environment}"
  retention_in_days = 7
}

# Serviço ECS (Padrão adaptado)
resource "aws_ecs_service" "elasticsearch" {
  name            = "${var.name}-${var.environment}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.elasticsearch.arn

  depends_on = [aws_efs_mount_target.es_data]

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.elasticsearch.id]
    assign_public_ip = false
  }

  enable_execute_command = true

  service_registries {
    registry_arn = aws_service_discovery_service.elasticsearch.arn
  }

  tags = {
    Environment = var.environment
  }
}

# Service Discovery (Padrão adaptado)
resource "aws_service_discovery_service" "elasticsearch" {
  name = var.name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      type = "A"
      ttl  = 10
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}