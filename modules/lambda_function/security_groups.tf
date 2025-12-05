resource "aws_security_group" "lambda" {
  count = length(var.subnet_ids) > 0 && length(var.security_group_ids) == 0 ? 1 : 0

  name        = "${var.function_name}-sg"
  description = "Security group for Lambda function ${var.function_name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.function_name}-sg"
  }
}

resource "aws_security_group_rule" "allow_lambda_to_efs" {
  count = var.allow_efs_ingress ? 1 : 0

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = var.efs_security_group_id
  source_security_group_id = aws_security_group.lambda[0].id
  description              = "Permite que a Lambda acesse o EFS via NFS"
}

# sg-06cff96caf4cd1fde - airflow-dags-sync-to-efs-sg


# sgr-08118c504f7b88436
# sgr-0509358ee4e38e929

# ?sg-06cff96caf4cd1fde - airflow-dags-sync-to-efs-sg



# aws lambda invoke \
#     --function-name airflow-dags-sync-to-efs \
#     --payload "{\"s3_file_name\": \"airflow-dags/dags-2025-11-18T19-20-52.zip\"}" \
#     --cli-binary-format raw-in-base64-out \
#     --log-type Tail \
#     response.json



# aws lambda invoke \
#     --function-name airflow-dags-sync-to-efs \
#     --payload "{\"s3_file_name\": \"airflow-dags/dags-2025-11-18T19-20-52.zip\"}" \
#     --cli-binary-format raw-in-base64-out \
#     --log-type Tail \
#     response.json

# An error occurred (EFSMountConnectivityException) when calling the Invoke operation: The function couldn't connect to the Amazon EFS file system with access point arn:aws:elasticfilesystem:us-east-1:414669981241:access-point/fsap-0f40ef87e9bd017bf. Check your network configuration and try again.




