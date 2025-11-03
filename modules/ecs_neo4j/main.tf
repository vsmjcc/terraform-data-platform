# --- Bloco de Geração de Senha (Igual) ---
resource "random_password" "neo4j_password" {
  length  = 16
  special = true
  override_special = "_!#$%^&*()-"
}

resource "aws_secretsmanager_secret" "neo4j_password" {
  name = "${var.name}-${var.environment}-neo4j-4-4-db-password"
}

resource "aws_secretsmanager_secret_version" "neo4j_password_version" {
  secret_id     = aws_secretsmanager_secret.neo4j_password.id
  secret_string = jsonencode({
    username = "neo4j"
    password = random_password.neo4j_password.result
  })
}

# --- Bloco IAM (Igual) ---
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

# --- Bloco EFS ---

# Security Group para o EFS (REMOVIDA a regra de ingress inline)
resource "aws_security_group" "efs" {
  name        = "neo4j-efs-${var.environment}-sg"
  description = "Security group for Neo4j EFS"
  vpc_id      = var.vpc_id

  # A regra de ingress foi movida para um recurso "aws_security_group_rule"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "neo4j-efs-${var.environment}-sg"
    Environment = var.environment
  }
}

# O File System EFS (Igual)
resource "aws_efs_file_system" "neo4j_data" {
  creation_token = "neo4j-data-${var.environment}"
  tags = {
    Name        = "neo4j-data-${var.environment}"
    Environment = var.environment
  }
}

# Mount Targets para o EFS (Igual)
resource "aws_efs_mount_target" "neo4j_data" {
  for_each          = toset(var.private_subnet_ids) 
  file_system_id    = aws_efs_file_system.neo4j_data.id
  subnet_id         = each.value
  security_groups   = [aws_security_group.efs.id]
}

# Ponto de Acesso EFS (Igual)
resource "aws_efs_access_point" "neo4j_data" {
  file_system_id = aws_efs_file_system.neo4j_data.id
  root_directory {
    path = "/data" 
    creation_info {
      owner_gid   = 7474 
      owner_uid   = 7474 
      permissions = "0755"
    }
  }
  posix_user {
    gid = 7474
    uid = 7474
  }
}

# --- Bloco Neo4j ---

# Security Group do Neo4j (REMOVIDA a regra de egress inline para EFS)
resource "aws_security_group" "neo4j" {
  name        = "neo4j-${var.environment}-sg"
  description = "Security group for Neo4j Fargate"
  vpc_id      = var.vpc_id
  
  egress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    # Note que o argumento aqui é "security_groups" (plural, lista)
    security_groups = [aws_security_group.efs.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "neo4j-${var.environment}-sg"
    Environment = var.environment
  }
}

# --- REGRAS DE SECURITY GROUP SEPARADAS (A CORREÇÃO) ---

# Regra 1: Permite EFS (Ingress) receber do Neo4j
resource "aws_security_group_rule" "allow_neo4j_to_efs" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2049 # NFS
  to_port                  = 2049
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.neo4j.id
  description              = "Allow Neo4j to access EFS"
}

# # Regra 2: Permite Neo4j (Egress) falar com o EFS
# resource "aws_security_group_rule" "allow_efs_from_neo4j" {
#   type                        = "egress" # <--- ADICIONE ESTA LINHA
#   from_port                   = 2049
#   to_port                     = 2049
#   protocol                    = "tcp"
#   security_group_id           = aws_security_group.neo4j.id # De: Neo4j
#   destination_security_group_id = aws_security_group.efs.id # Para: EFS
# }

# --- FIM DA CORREÇÃO ---


# Regras de Ingress para o Amundsen (Igual)
resource "aws_security_group_rule" "allow_bolt" {
  count             = length(var.allowed_security_groups) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 7687 # Porta Bolt
  to_port           = 7687
  protocol          = "tcp"
  security_group_id = aws_security_group.neo4j.id
  source_security_group_id = var.allowed_security_groups[count.index]
}

resource "aws_security_group_rule" "allow_http" {
  count             = length(var.allowed_security_groups) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 7474 # Porta HTTP (Browser)
  to_port           = 7474
  protocol          = "tcp"
  security_group_id = aws_security_group.neo4j.id
  source_security_group_id = var.allowed_security_groups[count.index]
}


# Definição da Task (Igual)
resource "aws_ecs_task_definition" "neo4j" {
  family                   = "neo4j-${var.environment}"
 requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024" 
  memory                   = "2048" 
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn

  volume {
    name = "neo4j-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.neo4j_data.id
      transit_encryption = "ENABLED"
      
      # O access_point_id deve estar dentro deste bloco:
      authorization_config {
        access_point_id = aws_efs_access_point.neo4j_data.id
      }
    }
  }

  container_definitions = jsonencode([
    {
     name      = "neo4j"
      image     = "neo4j:4.4-community"
      essential = true
      
      portMappings = [
        {
          containerPort = 7474 
          hostPort      = 7474
          protocol      = "tcp"
        },
        {
          containerPort = 7687 
          hostPort      = 7687
          protocol      = "tcp"
        }
      ],

      mountPoints = [
        {
          sourceVolume  = "neo4j-data"
          containerPath = "/data" 
          readOnly      = false
        }
      ],

      environment = [
        {
          name  = "NEO4J_AUTH"
          value = "neo4j/${random_password.neo4j_password.result}" 
        }
      ],

     logConfiguration = {
       logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/neo4j-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "neo4j"
        }
      }
    }
  ])
}

# CloudWatch (Igual)
resource "aws_cloudwatch_log_group" "neo4j" {
  name              = "/ecs/neo4j-${var.environment}"
  retention_in_days = 7
}

# Serviço ECS (Igual)
resource "aws_ecs_service" "neo4j" {
  name            = "neo4j-${var.environment}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.neo4j.arn

  depends_on = [aws_efs_mount_target.neo4j_data]

  network_configuration {
    subnets          = var.private_subnet_ids
   security_groups  = [aws_security_group.neo4j.id]
    assign_public_ip = false
  }

  enable_execute_command = true

  service_registries {
    registry_arn = aws_service_discovery_service.neo4j.arn
  }

  tags = {
    Environment = var.environment
  }
}

# Service Discovery (Igual)
resource "aws_service_discovery_service" "neo4j" {
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