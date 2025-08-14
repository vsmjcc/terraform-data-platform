data "aws_iam_policy_document" "crawler_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "AWSGlueCrawlerRole-${var.project}-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.crawler_trust.json
  tags               = var.tags
}

# Permissões S3 (list e get limitada aos prefixos)
data "aws_iam_policy_document" "s3_read" {
  statement {
    sid     = "ListSpecificBuckets"
    actions = ["s3:ListBucket"]
    resources = var.read_bucket_arns
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = var.read_prefixes
    }
  }

  statement {
    sid       = "ReadObjects"
    actions   = ["s3:GetObject"]
    resources = [
      for p in var.read_prefixes :
      # transforma "arn:...:bucket/prefix/*" quando bucket veio em read_bucket_arns
      # aqui assumimos que prefixes já vêm completos com "arn:aws:s3:::bucket/prefix/*"
      # Se você passar sem arn, pode adaptar para construir o arn aqui.
      "arn:aws:s3:::${replace(p, "arn:aws:s3:::", "")}"
    ]
  }
}

resource "aws_iam_policy" "s3_read" {
  name   = "GlueCrawlerS3Read-${var.project}-${var.name}"
  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_role_policy_attachment" "service_managed" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_read.arn
}

resource "aws_glue_crawler" "this" {
  name          = var.name
  role          = aws_iam_role.this.arn
  database_name = var.database_name

  dynamic "s3_target" {
    for_each = var.s3_target_paths
    content {
      path = s3_target.value
    }
  }

  schema_change_policy {
    update_behavior = var.update_behavior
    delete_behavior = var.delete_behavior
  }

  recrawl_policy {
    recrawl_behavior = var.recrawl_behavior
  }

  # agenda opcional
  count    = length(var.schedule) > 0 ? 1 : 0
  schedule = length(var.schedule) > 0 ? var.schedule : null

  tags = var.tags
}
