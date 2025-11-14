
resource "random_password" "es_password" {
  length           = 16
  special          = true
  override_special = "_!#$%^&*()-"
}

resource "aws_secretsmanager_secret" "es_password" {
  name = "${var.name}-${var.environment}-es-password"
}

resource "aws_secretsmanager_secret_version" "es_password_version" {
  secret_id     = aws_secretsmanager_secret.es_password.id
  secret_string = jsonencode({
    username = "elastic"
    password = random_password.es_password.result
  })
}

resource "aws_ecs_task_definition" "elasticsearch" {
  family                   = "${var.name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn

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

      portMappings = [{
        containerPort = 9200
        hostPort      = 9200
        protocol      = "tcp"
      }]

      mountPoints = [{
        sourceVolume  = "es-data"
        containerPath = "/usr/share/elasticsearch/data"
        readOnly      = false
      }]

      environment = [
        { name = "discovery.type", value = "single-node" },
        { name = "xpack.security.enabled", value = "true" },
        { name = "ELASTIC_PASSWORD", value = random_password.es_password.result },
        { name = "ES_JAVA_OPTS", value = var.es_java_opts }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.elasticsearch.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])
}

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