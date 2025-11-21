# ---------- Webserver ----------
resource "aws_ecs_task_definition" "airflow_webserver" {
  family                   = "airflow-${var.environment}-webserver"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-webserver"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      command   = ["airflow", "webserver"]
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__WEBSERVER__WORKERS", value = "2" },
        { name = "AIRFLOW__CORE__LOAD_EXAMPLES", value = "False" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOGGING", value = "true" },
        { name = "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER", value = "s3://${module.airflow_logs_bucket.bucket_name}" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID", value = "aws_default" },
        { name = "AIRFLOW__CORE__DEFAULT_TIMEZONE", value = "America/Sao_Paulo" },
        { name = "AIRFLOW__WEBSERVER__BASE_URL", value = "https://airflow.${var.dns_zone_name}" },
        { name = "AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX", value = "true" }
      ]
      
      secrets = [{
        name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
        valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
      }]
      mountPoints = [{
        sourceVolume  = "airflow-dags"
        containerPath = "/opt/airflow/dags"
        readOnly      = false
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "webserver"
        }
      }
    }
  ])

  volume {
    name = "airflow-dags"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  tags = { Environment = var.environment }
}

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

  depends_on = [aws_lb_listener.airflow_https]
  tags       = { Environment = var.environment }
}

# ---------- Scheduler ----------
resource "aws_ecs_task_definition" "airflow_scheduler" {
  family                   = "airflow-${var.environment}-scheduler"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-scheduler"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      command   = ["airflow", "scheduler"]
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__CORE__LOAD_EXAMPLES", value = "False" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" },
        { name = "AIRFLOW__SCHEDULER__STANDALONE_DAG_PROCESSOR", value = "false" },
        { name = "AIRFLOW__CORE__MIN_FILE_PROCESS_INTERVAL", value = "10" },
        { name = "AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL", value = "30" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOGGING", value = "true" },
        { name = "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER", value = "s3://${module.airflow_logs_bucket.bucket_name}" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID", value = "aws_default" },
        { name = "AIRFLOW__CORE__DEFAULT_TIMEZONE", value = "America/Sao_Paulo" }
      ]
      secrets = [{
        name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
        valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
      }]
      mountPoints = [{
        sourceVolume  = "airflow-dags"
        containerPath = "/opt/airflow/dags"
        readOnly      = true
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "scheduler"
        }
      }
    }
  ])

  volume {
    name = "airflow-dags"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  tags = { Environment = var.environment }
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
  tags       = { Environment = var.environment }
}

# ---------- Workers (count) ----------
resource "aws_ecs_task_definition" "airflow_worker" {
  count                    = var.worker_count
  family                   = "airflow-${var.environment}-worker-${count.index}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-worker"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      command   = ["airflow", "celery", "worker"]
      environment = [
        { name = "AIRFLOW__CORE__EXECUTOR", value = "CeleryExecutor" },
        { name = "AIRFLOW__LOGGING__LOGGING_LEVEL", value = "DEBUG" },
        { name = "AIRFLOW__CELERY__BROKER_URL", value = "redis://${var.redis_host}:6379/0" },
        { name = "AIRFLOW__CELERY__WORKER_CONCURRENCY", value = "2" },
        { name = "AIRFLOW__CELERY__WORKER_MAX_TASKS_PER_CHILD", value = "5" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOGGING", value = "true" },
        { name = "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER", value = "s3://${module.airflow_logs_bucket.bucket_name}" },
        { name = "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID", value = "aws_default" },
        { name = "AIRFLOW__CORE__DEFAULT_TIMEZONE", value = "America/Sao_Paulo" }
      ]
      secrets = [{
        name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
        valueFrom = aws_secretsmanager_secret.sqlalchemy_conn.arn
      }]
      mountPoints = [{
        sourceVolume  = "airflow-dags"
        containerPath = "/opt/airflow/dags"
        readOnly      = true
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "worker"
        }
      }
    }
  ])

  volume {
    name = "airflow-dags"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  tags = { Environment = var.environment }
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
  tags       = { Environment = var.environment }
}