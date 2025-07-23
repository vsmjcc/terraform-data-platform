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
  skip_destroy      = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "sqlalchemy_conn" {
  name = "zerezes-data-${var.environment}-AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
}

resource "aws_secretsmanager_secret_version" "sqlalchemy_conn_version" {
  secret_id     = aws_secretsmanager_secret.sqlalchemy_conn.id
  secret_string = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${var.db_host}/${var.db_name}"
}
