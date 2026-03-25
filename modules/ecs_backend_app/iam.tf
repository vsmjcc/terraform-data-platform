resource "aws_iam_role" "exec" {
  name = "${local.resource_prefix}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${local.resource_prefix}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}


resource "aws_iam_role_policy" "execution_read_secrets" {
  count = length(var.secret_arns_for_execution_role) > 0 ? 1 : 0

  name = "${local.resource_prefix}-execution-read-secrets"
  role = aws_iam_role.exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = var.secret_arns_for_execution_role
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_extra" {
  count      = length(var.task_role_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = var.task_role_policy_arns[count.index]
}