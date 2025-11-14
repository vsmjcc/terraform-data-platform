
resource "random_password" "neo4j_password" {
  length           = 16
  special          = true
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
        { containerPort = 7474, hostPort = 7474, protocol = "tcp" },
        { containerPort = 7687, hostPort = 7687, protocol = "tcp" }
      ]

      mountPoints = [{
        sourceVolume  = "neo4j-data"
        containerPath = "/data"
        readOnly      = false
      }]

      environment = [{
        name  = "NEO4J_AUTH"
        value = "neo4j/${random_password.neo4j_password.result}"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.neo4j.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "neo4j"
        }
      }
    }
  ])
}

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