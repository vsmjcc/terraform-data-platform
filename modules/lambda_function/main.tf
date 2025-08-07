# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.create_log_group ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}

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
  count = var.allow_efs_ingress && var.efs_security_group_id != null && length(var.subnet_ids) > 0 ? 1 : 0

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = var.efs_security_group_id
  source_security_group_id = aws_security_group.lambda[0].id
  description              = "Permite que a Lambda acesse o EFS via NFS"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "${var.function_name}-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::zrzs-dev-packages",
          "arn:aws:s3:::zrzs-dev-packages/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.lambda[0].id]
    }
  }

  dynamic "file_system_config" {
    for_each = var.efs_arn != null ? [1] : []
    content {
      arn              = var.efs_arn
      local_mount_path = var.efs_mount_path
    }
  }

  lifecycle {
    ignore_changes = [
      s3_key,
      s3_bucket,
      source_code_hash
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = length(var.subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_apigatewayv2_api" "this" {
  count         = var.enable_http_api ? 1 : 0
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_apigw" {
  count         = var.enable_http_api && var.public_access ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "this" {
  count                    = var.enable_http_api ? 1 : 0
  api_id                  = aws_apigatewayv2_api.this[0].id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.this.invoke_arn
  integration_method      = "POST"
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  count     = var.enable_http_api ? 1 : 0
  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.this[0].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  count       = var.enable_http_api ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true
}

# Optional custom DNS record
resource "aws_route53_record" "custom_dns" {
  count   = var.enable_http_api && var.dns_zone_id != null && var.enable_custom_domain ? 1 : 0
  zone_id = var.dns_zone_id
  name    = "${var.function_name}.${data.aws_route53_zone.selected[0].name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].target_domain_name]
}

data "aws_route53_zone" "selected" {
  count   = var.dns_zone_id != null ? 1 : 0
  zone_id = var.dns_zone_id
}

# Cria domínio customizado usando o certificado ACM (wildcard *.data.zerezes.dev)
resource "aws_apigatewayv2_domain_name" "custom" {
  count = var.enable_http_api && var.enable_custom_domain ? 1 : 0
  domain_name         = "${var.function_name}.${data.aws_route53_zone.selected[0].name}"
  domain_name_configuration {
    certificate_arn = var.dns_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Faz o mapeamento da API para esse domínio customizado
resource "aws_apigatewayv2_api_mapping" "custom" {
  count       = var.enable_http_api && var.enable_custom_domain ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.custom[0].domain_name
  stage       = aws_apigatewayv2_stage.default[0].name
}
