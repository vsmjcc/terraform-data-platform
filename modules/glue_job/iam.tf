locals {
  all_buckets = distinct(concat(var.data_buckets, [var.script_bucket, var.temp_bucket]))
}

data "aws_iam_policy_document" "glue_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue" {
  name               = "AWSGlueServiceRole-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.glue_trust.json
  tags               = var.tags
}

# S3 access (listar buckets específicos + R/W nos objetos)
data "aws_iam_policy_document" "glue_s3" {
  statement {
    sid     = "ListAll"
    effect  = "Allow"
    actions = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid     = "ListSpecificBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [for b in local.all_buckets : "arn:aws:s3:::${b}"]
  }

  statement {
    sid     = "ObjectsRW"
    effect  = "Allow"
    actions = [
      "s3:GetObject","s3:PutObject","s3:DeleteObject",
      "s3:AbortMultipartUpload","s3:ListBucketMultipartUploads"
    ]
    resources = [for b in local.all_buckets : "arn:aws:s3:::${b}/*"]
  }
}

resource "aws_iam_policy" "glue_s3" {
  name   = "${var.name}-glue-s3"
  policy = data.aws_iam_policy_document.glue_s3.json
}

# CloudWatch Logs + Glue Catalog + (opcional EC2 p/ VPC)
data "aws_iam_policy_document" "glue_logs_catalog" {
  statement {
    sid     = "CWLogs"
    effect  = "Allow"
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogStreams"]
    resources = ["*"]
  }

  statement {
    sid     = "GlueCatalog"
    effect  = "Allow"
    actions = [
      "glue:Get*","glue:BatchGet*","glue:List*",
      "glue:CreateDatabase","glue:UpdateDatabase","glue:DeleteDatabase",
      "glue:CreateTable","glue:UpdateTable","glue:DeleteTable"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.use_vpc ? [1] : []
    content {
      sid     = "EC2ForGlueVPC"
      effect  = "Allow"
      actions = [
        "ec2:CreateNetworkInterface","ec2:DeleteNetworkInterface","ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSubnets","ec2:DescribeSecurityGroups","ec2:DescribeVpcs"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "glue_logs_catalog" {
  name   = "${var.name}-glue-logs-catalog"
  policy = data.aws_iam_policy_document.glue_logs_catalog.json
}

# (Opcional) KMS
data "aws_iam_policy_document" "kms" {
  count = length(var.kms_keys) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt","kms:Encrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey"]
    resources = var.kms_keys
  }
}

resource "aws_iam_policy" "kms" {
  count  = length(var.kms_keys) > 0 ? 1 : 0
  name   = "${var.name}-glue-kms"
  policy = data.aws_iam_policy_document.kms[0].json
}

# Attach
resource "aws_iam_role_policy_attachment" "attach_service_managed" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue_s3.arn
}

resource "aws_iam_role_policy_attachment" "attach_logs_catalog" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue_logs_catalog.arn
}

resource "aws_iam_role_policy_attachment" "attach_kms" {
  count      = length(var.kms_keys) > 0 ? 1 : 0
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.kms[0].arn
}
