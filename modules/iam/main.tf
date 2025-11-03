data "aws_caller_identity" "current" {}

# Role usada pelo GitHub Actions para deploy
resource "aws_iam_role" "app_deploy_role" {
  name = "zerezes-app-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::414669981241:oidc-provider/token.actions.githubusercontent.com"
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

# Policy para deploy no ECS
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
          "arn:aws:iam::414669981241:role/airflow-dev-task-execution-role",
          "arn:aws:iam::414669981241:role/*-task-execution-role",
          "arn:aws:iam::414669981241:role/*-task-role"
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


# Policy para deploy de Lambdas
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
        Resource = "arn:aws:lambda:us-east-1:414669981241:function:*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_dag_upload_policy" {
  name        = "zerezes-app-s3-upload-policy"
  description = "Permite o upload de DAGs no bucket zrzs-dev-packages"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "arn:aws:s3:::zrzs-dev-packages/airflow-dags/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_dag_upload_policy" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.s3_dag_upload_policy.arn
}


resource "aws_iam_policy" "s3_etls_glue_upload_policy" {
  name        = "zerezes-etls-glue-s3-upload-policy"
  description = "Permite o upload e leitura dos scripts Glue no bucket zrzs-dev-etls"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::zrzs-dev-etls/glue/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::zrzs-dev-etls",
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "glue/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_etls_glue_upload_policy" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.s3_etls_glue_upload_policy.arn
}

# ---------------------------------------------------------
# Permissão para as Lambdas escreverem no bucket bronze
# ---------------------------------------------------------

# Identity policy mínima para as roles ingest-*-to-bronze (só S3 PutObject no bronze)
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

# Bucket policy para aceitar somente as roles ingest-*-to-bronze
resource "aws_s3_bucket_policy" "bronze_bucket_policy" {
  bucket = "zrzs-${var.environment}-data-lake-bronze"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid:      "AllowPutFromIngestToBronze",
        Effect:   "Allow",
        Principal: "*",
        Action:   "s3:PutObject",
        Resource: "arn:aws:s3:::zrzs-${var.environment}-data-lake-bronze/*",
        Condition: {
          StringLike: {
            "aws:PrincipalArn": "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/ingest-*-to-bronze-lambda-role/*"
          }
        }
      }
    ]
  })
}


# ---------------------------------------------------------
# Attachments
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ecs_deploy_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.ecs_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "secretsmanager_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_deploy_attach" {
  role       = aws_iam_role.app_deploy_role.name
  policy_arn = aws_iam_policy.lambda_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_bronze_write_to_lambda" {
  role       = "ingest-typeform-to-bronze-lambda-role"
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_orders_bronze_write_to_lambda" {
  role       = "ingest-shopify-orders-to-bronze-lambda-role" 
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_products_bronze_write_to_lambda" {
  role       = "ingest-shopify-products-to-bronze-lambda-role" 
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_shopify_customers_bronze_write_to_lambda" {
  role       = "ingest-shopify-customers-to-bronze-lambda-role" 
  policy_arn = aws_iam_policy.bronze_write_policy.arn
}