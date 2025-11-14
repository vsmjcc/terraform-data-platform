
resource "aws_iam_role" "app_deploy_role" {
  name = "zerezes-app-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:zerezes/*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "ecs_deploy_policy" {
  name        = "zerezes-app-ecs-deploy-policy"
  description = "Permite registrar Task Definitions e fazer Update no Service no ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:ListClusters",
          "ecs:RunTask"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          "arn:aws:iam::${local.account_id}:role/airflow-${var.environment}-task-execution-role",
          "arn:aws:iam::${local.account_id}:role/*-task-execution-role",
          "arn:aws:iam::${local.account_id}:role/*-task-role"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_deploy_policy" {
  name        = "zerezes-app-lambda-deploy-policy"
  description = "Permite deploy de funções Lambda pelo GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:InvokeFunction"
        ],
        Resource = "arn:aws:lambda:us-east-1:${local.account_id}:function:*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_dag_upload_policy" {
  name        = "zerezes-app-s3-upload-policy"
  description = "Permite o upload de DAGs no bucket zrzs-${var.environment}-packages"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "arn:aws:s3:::zrzs-${var.environment}-packages/airflow-dags/*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_etls_glue_upload_policy" {
  name        = "zerezes-etls-glue-s3-upload-policy" 
  description = "Permite o upload e leitura dos scripts Glue no bucket zrzs-dev-etls"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject"],
        Resource = "arn:aws:s3:::zrzs-dev-etls/glue/*"
      },
      {
        Effect = "Allow",
        Action = "s3:ListBucket",
        Resource = "arn:aws:s3:::zrzs-dev-etls",
        Condition = {
          StringLike = { "s3:prefix" = ["glue/*"] }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "bronze_write_policy" {
  name = "zrzs-${var.environment}-data-lake-bronze-write-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject"],
      Resource = "arn:aws:s3:::zrzs-${var.environment}-data-lake-bronze/*"
    }]
  })
}