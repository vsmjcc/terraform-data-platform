module "frontend_app" {
  source = "../frontend_static_app"

  name            = "data-lake-settings"
  environment     = var.environment
  bucket_name     = "zrzs-${var.environment}-data-lake-settings-front"
  zone_id         = var.zone_id
  zone_name       = var.zone_name
  subdomain       = var.subdomain
  certificate_arn = var.certificate_arn

  is_spa = true
  tags   = var.tags
}


module "backend_app" {
  source = "../ecs_backend_app"

  name               = "data-lake-settings-api"
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  cluster_name       = var.ecs_cluster_name

  create_ecr_repository = true
  image_tag             = "latest"
  container_image       = var.backend_container_image

  container_port = 8000
  cpu            = 512
  memory         = 1024
  desired_count  = 1

  health_check_path = "/health"

  environment_variables = {
    APP_ENV               = var.environment
    AWS_REGION            = var.aws_region
    SETTINGS_BUCKET       = "zrzs-${var.environment}-data-lake-settings"
    SETTINGS_PREFIX       = "channel-classification"
    APP_FRONTEND_URL      = "https://${var.subdomain}.${var.zone_name}"
    ALLOWED_EMAIL_DOMAIN  = "zerezes.com.br"
    GOOGLE_REDIRECT_URI   = "https://${var.subdomain}-api.${var.zone_name}/auth/callback"
    CORS_ALLOWED_ORIGINS  = "https://${var.subdomain}.${var.zone_name}"
    SESSION_HTTPS_ONLY    = "true"
    SESSION_SAME_SITE     = "lax"
  }

  secrets = {
    SESSION_SECRET                = "${aws_secretsmanager_secret.backend_env.arn}:SESSION_SECRET::"
    GOOGLE_CLIENT_SECRET          = "${aws_secretsmanager_secret.backend_env.arn}:GOOGLE_CLIENT_SECRET::"
    GOOGLE_SERVICE_ACCOUNT_BASE64 = "${aws_secretsmanager_secret.backend_env.arn}:GOOGLE_SERVICE_ACCOUNT_BASE64::"

    GOOGLE_CLIENT_ID              = "${aws_secretsmanager_secret.backend_env.arn}:GOOGLE_CLIENT_ID::"
    GOOGLE_ALLOWED_GROUP          = "${aws_secretsmanager_secret.backend_env.arn}:GOOGLE_ALLOWED_GROUP::"
    GOOGLE_WORKSPACE_ADMIN_EMAIL  = "${aws_secretsmanager_secret.backend_env.arn}:GOOGLE_WORKSPACE_ADMIN_EMAIL::"
  }

  secret_arns_for_execution_role = [
    aws_secretsmanager_secret.backend_env.arn
  ]

  task_role_policy_arns = [
    aws_iam_policy.data_lake_files_rw.arn
  ]

  dns_zone_id         = var.zone_id
  dns_zone_name       = var.zone_name
  dns_certificate_arn = var.certificate_arn
  subdomain           = "${var.subdomain}-api"

  tags = var.tags
}