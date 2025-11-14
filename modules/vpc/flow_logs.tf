resource "aws_s3_bucket" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = "zrzs-${var.environment}-vpc-flow-logs-${var.region}"
  force_destroy = true

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.environment}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.environment}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_logs[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject"],
      Resource = "${aws_s3_bucket.vpc_flow_logs[0].arn}/*"
    }]
  })
}

resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.vpc_flow_logs[0].arn

  tags = {
    Name = "${var.environment}-vpc-flow-log"
  }
}