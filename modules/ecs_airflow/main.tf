# IAM Role
resource "aws_iam_role" "task_execution_role" {
  name = "airflow-${var.environment}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_exec_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "airflow" {
  name              = "/ecs/airflow-${var.environment}-v2"
  retention_in_days = 7
  skip_destroy      = true

  tags = {
    Environment = var.environment
  }
}

# Secret
resource "aws_secretsmanager_secret" "sqlalchemy_conn" {
  name = "zerezes-data-${var.environment}-AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
}

resource "aws_secretsmanager_secret_version" "sqlalchemy_conn_version" {
  secret_id     = aws_secretsmanager_secret.sqlalchemy_conn.id
  secret_string = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${var.db_host}/${var.db_name}"
}

# Task Definition
resource "aws_ecs_task_definition" "airflow_webserver" {
  family                   = "airflow-${var.environment}-webserver"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-webserver",
      image     = "${var.ecr_repo_url}:latest",
      essential = true,
      command   = ["airflow", "webserver"],
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ],
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__WEBSERVER__WORKERS", value = "2" },
        { name = "AIRFLOW__CORE__LOAD_EXAMPLES", value = "False" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" }
      ],
      secrets = [
        {
          name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN",
          valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "webserver"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "airflow_scheduler" {
  family                   = "airflow-${var.environment}-scheduler"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-scheduler",
      image     = "${var.ecr_repo_url}:latest",
      essential = true,
      command   = ["airflow", "scheduler"],
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__CORE__LOAD_EXAMPLES", value = "False" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" }
      ],
      secrets = [
        {
          name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN",
          valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "scheduler"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "airflow_worker" {
  count                    = var.worker_count
  family                   = "airflow-${var.environment}-worker-${count.index}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-worker",
      image     = "${var.ecr_repo_url}:latest",
      essential = true,
      command   = ["airflow", "celery", "worker"],
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" }
      ],
      secrets = [
        {
          name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN",
          valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "worker"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "airflow_dag_processor" {
  family                   = "airflow-${var.environment}-dag-processor"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-dag-processor",
      image     = "${var.ecr_repo_url}:latest",
      essential = true,
      command   = ["airflow", "dag-processor"],
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__SCHEDULER__STANDALONE_DAG_PROCESSOR", value = "true" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" }
      ],
      secrets = [
        {
          name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN",
          valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "dag-processor"
        }
      }
    }
  ])
}



# Security Groups
resource "aws_security_group" "alb" {
  name        = "airflow-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
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
    Name        = "airflow-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "airflow" {
  name        = "airflow-${var.environment}-ecs-sg"
  description = "Security group for Airflow ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description       = "Allow traffic from ALB"
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    security_groups   = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "airflow-${var.environment}-ecs-sg"
    Environment = var.environment
  }
}

# Load Balancer
resource "aws_lb" "airflow" {
  name               = "airflow-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "airflow" {
  name        = "airflow-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2 
    unhealthy_threshold = 10
    matcher             = "200"
  }
}

resource "aws_lb_listener" "airflow" {
  load_balancer_arn = aws_lb.airflow.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }
}

# ECS Service
resource "aws_ecs_service" "airflow" {
  name            = "airflow-${var.environment}-webserver"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.airflow_webserver.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.airflow.arn
    container_name   = "airflow-webserver"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.airflow]
}

resource "aws_ecs_service" "airflow_scheduler" {
  name            = "airflow-${var.environment}-scheduler"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.airflow_scheduler.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.airflow_scheduler]
}

resource "aws_ecs_service" "airflow_worker" {
  count           = var.worker_count
  name            = "airflow-${var.environment}-worker-${count.index}"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.airflow_worker[count.index].arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.airflow_worker]
}


resource "aws_ecs_service" "airflow_dag_processor" {
  name            = "airflow-${var.environment}-dag-processor"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.airflow_dag_processor.arn

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.airflow_dag_processor]
}



