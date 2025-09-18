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

resource "aws_security_group" "redis" {
  name        = "redis-${var.environment}-sg"
  description = "Security group for Redis Fargate"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "redis-${var.environment}-sg"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "redis" {
  family                   = "redis-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:7.2"
      essential = true
      portMappings = [
        {
          containerPort = 6379
          hostPort      = 6379
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/redis-${var.environment}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "redis"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "redis" {
  name              = "/ecs/redis-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_service" "redis" {
  name            = "redis-${var.environment}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.redis.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.redis.id]
    assign_public_ip = false
  }

  enable_execute_command = true

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  depends_on = [aws_service_discovery_service.redis]

  tags = {
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "redis" {
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
