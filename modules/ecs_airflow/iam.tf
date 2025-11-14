# ---------- IAM Role ----------
resource "aws_iam_role" "task_execution_role" {
  name = "airflow-${var.environment}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# ---------- Políticas padrão ----------
resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_exec_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# ---------- Glue Catalog (leitura) ----------
resource "aws_iam_role_policy" "glue_catalog_read" {
  name = "GlueCatalogReadForAmundsen"
  role = aws_iam_role.task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "GlueCatalogRead",
      Effect = "Allow",
      Action = [
        "glue:SearchTables", "glue:GetDatabase", "glue:GetDatabases",
        "glue:GetTable", "glue:GetTables", "glue:GetTableVersion",
        "glue:GetTableVersions", "glue:GetPartition", "glue:GetPartitions",
        "glue:GetUserDefinedFunctions", "glue:GetTags"
      ],
      Resource = [
        "arn:aws:glue:${var.aws_region}:${local.account_id}:catalog",
        "arn:aws:glue:${var.aws_region}:${local.account_id}:database/*",
        "arn:aws:glue:${var.aws_region}:${local.account_id}:table/*"
      ]
    }]
  })
}

# ---------- S3 Logs ----------
resource "aws_iam_policy" "airflow_logs" {
  name = "airflow-logs-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      Resource = [
        module.airflow_logs_bucket.bucket_arn,
        "${module.airflow_logs_bucket.bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_logs_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_logs.arn
}

# ---------- Data Lake (bronze) ----------
resource "aws_iam_policy" "airflow_data_lake_access_bronze" {
  name = "airflow-${var.environment}-data-lake-access-bronze"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-bronze",
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-bronze/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_airflow_data_lake_access-bronze" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_data_lake_access_bronze.arn
}

# ---------- Data Lake (silver + gold) ----------
resource "aws_iam_policy" "airflow_data_lake_access_silver_gold" {
  name = "airflow-${var.environment}-data-lake-access-silver-gold"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"],
      Resource = [
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-silver",
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-silver/*",
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-gold",
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-gold/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_airflow_data_lake_access_silver_gold" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_data_lake_access_silver_gold.arn
}

# ---------- Data Lake (files) ----------
resource "aws_iam_policy" "airflow_data_lake_access_files" {
  name = "airflow-${var.environment}-data-lake-access-files"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-files",
        "arn:aws:s3:::zrzs-${var.environment}-data-lake-files/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_airflow_data_lake_access-files" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_data_lake_access_files.arn
}

# ---------- Glue Jobs ----------
data "aws_iam_policy_document" "airflow_glue" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetJob", "glue:StartJobRun", "glue:GetJobRun",
      "glue:GetJobRuns", "glue:BatchStopJobRun"
    ]
    resources = ["arn:aws:glue:us-east-1:${data.aws_caller_identity.current.account_id}:job/*"]
  }
}

resource "aws_iam_policy" "airflow_glue_policy" {
  name   = "airflow-glue-job-policy"
  policy = data.aws_iam_policy_document.airflow_glue.json
}

resource "aws_iam_role_policy_attachment" "attach_airflow_glue_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_glue_policy.arn
}

# ---------- Glue Crawlers ----------
data "aws_iam_policy_document" "airflow_glue_crawlers_all" {
  statement {
    sid    = "CrawlersStartGet"
    effect = "Allow"
    actions = [
      "glue:GetCrawler", "glue:GetCrawlerMetrics", "glue:StartCrawler",
      "glue:StopCrawler", "glue:StartCrawlerSchedule", "glue:StopCrawlerSchedule"
    ]
    resources = ["arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:crawler/*"]
  }

  statement {
    sid    = "ListCrawlers"
    effect = "Allow"
    actions = ["glue:ListCrawlers", "glue:GetCrawlerMetrics"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "airflow_glue_crawlers_all" {
  name   = "airflow-${var.environment}-glue-crawlers-all"
  policy = data.aws_iam_policy_document.airflow_glue_crawlers_all.json
}

resource "aws_iam_role_policy_attachment" "attach_airflow_glue_crawlers_all" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_glue_crawlers_all.arn
}


# ---------- Glue Logs (CloudWatch) ----------
resource "aws_iam_policy" "airflow_glue_logs" {
  name        = "airflow-glue-logs-policy"
  description = "Permite o Airflow ler logs do Glue no CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Resource = [
          "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/output:*",
          "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/error:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_airflow_glue_logs" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.airflow_glue_logs.arn
}