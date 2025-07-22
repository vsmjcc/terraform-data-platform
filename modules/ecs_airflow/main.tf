resource "aws_iam_role" "task_execution_role" {
  name = "airflow-${var.environment}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "airflow" {
  name              = "/ecs/airflow-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

locals {
  container_image = "apache/airflow:slim-latest-python3.9"
  service_names   = ["webserver", "scheduler", "worker", "flower"]
}

resource "aws_ecs_task_definition" "airflow" {
  family                   = "airflow-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-webserver"
      image     = "apache/airflow:slim-latest-python3.9"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      command = ["airflow", "api-server"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "airflow"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "airflow" {
  name          = "airflow-${var.environment}-webserver"
  cluster       = var.cluster_name
  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  task_definition = aws_ecs_task_definition.airflow.arn
}

