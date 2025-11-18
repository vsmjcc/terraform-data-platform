
# --- IAM Role de Execução (Usada por todos os 3 serviços) ---
resource "aws_iam_role" "task_execution" {
  name = "amundsen-services-${var.environment}-task-execution-role"
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



# --- Política para ler AMBOS os Secrets (Neo4j e ES) ---
data "aws_iam_policy_document" "read_secrets" {
  statement {
    sid    = "AllowReadNeo4jPassword"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.neo4j_password_secret_arn
    ]
  }

  statement {
    sid    = "AllowReadESPassword"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.es_password_secret_arn
    ]
  }
}

resource "aws_iam_policy" "read_secrets" {
  name   = "amundsen-services-${var.environment}-read-secrets-policy"
  policy = data.aws_iam_policy_document.read_secrets.json
}

resource "aws_iam_role_policy_attachment" "read_secrets" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.read_secrets.arn
}


resource "aws_secretsmanager_secret" "amundsen" {
  name        = "amundsen-${var.environment}"
  description = "Credenciais e configs sensíveis do Amundsen (${var.environment})"
}

resource "aws_secretsmanager_secret_version" "amundsen" {
  secret_id     = aws_secretsmanager_secret.amundsen.id

  secret_string = jsonencode({
    oidc_client_id     = "" 
    oidc_client_secret = ""
    oidc_discovery_url = ""
    google_sa_json     = ""
    required_group     = ""
    google_admin_subject= "amundsen-${var.environment}-sec@zerezes.com.br"
  })

  lifecycle {
    ignore_changes = [ secret_string, secret_binary ]
  }
}

data "aws_iam_policy_document" "amundsen_read_secrets" {
  statement {
    sid    = "AllowReadAmundsenSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.amundsen.arn
    ]
  }
}

resource "aws_iam_policy" "amundsen_read_secrets" {
  name   = "amundsen-${var.environment}-read-secrets"
  policy = data.aws_iam_policy_document.amundsen_read_secrets.json
}

resource "aws_iam_role_policy_attachment" "amundsen_task_attach_secret_read" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.amundsen_read_secrets.arn
}

# 1. A Role que a Task (aplicação) vai usar
resource "aws_iam_role" "ecs_task_role" {
  name = "amundsen-services-${var.environment}-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

# 2. O Policy Document com as permissões do SSM
data "aws_iam_policy_document" "ecs_exec" {
  statement {
    sid    = "AllowECSExec"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

# 3. A Política do IAM
resource "aws_iam_policy" "ecs_exec" {
  name   = "amundsen-services-${var.environment}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.ecs_exec.json
}

# 4. Anexa a Política à Role
resource "aws_iam_role_policy_attachment" "ecs_exec_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}