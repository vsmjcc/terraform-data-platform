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

# Permissão para deploy no ECS
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
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::414669981241:role/airflow-dev-task-execution-role"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attachments

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
