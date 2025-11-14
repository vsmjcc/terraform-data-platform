# iam.tf
resource "aws_iam_role" "lambda_role" {
  name = local.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = local.policy_name
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      { Effect = "Allow", Action = ["tag:GetResources"], Resource = "*" },
      {
        Effect = "Allow",
        Action = [
          "ecs:ListClusters", "ecs:ListServices", "ecs:DescribeServices",
          "ecs:UpdateService", "ecs:ListTagsForResource",
          "ecs:TagResource", "ecs:UntagResource"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups", "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:CreateOrUpdateTags", "autoscaling:DeleteTags"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances", "ec2:StopInstances", "ec2:StartInstances",
          "ec2:CreateTags", "ec2:DescribeTags"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances", "rds:StopDBInstance", "rds:StartDBInstance",
          "rds:ListTagsForResource"
        ],
        Resource = "*"
      }
    ]
  })
}