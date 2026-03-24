module "frontend_app" {
  source = "../frontend_static_app"

  name            = "data-lake-settings"
  environment     = var.environment
  bucket_name     = "zrzs-${var.environment}-data-lake-settings"
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

  container_image = var.backend_container_image

  # 🔒 defaults do produto
  container_port  = 8000
  cpu             = 512
  memory          = 1024
  desired_count   = 1

  health_check_path = "/health"

  environment_variables = {
    APP_ENV = var.environment
  }

  secrets = var.backend_secrets

  dns_zone_id         = var.zone_id
  dns_zone_name       = var.zone_name
  dns_certificate_arn = var.certificate_arn

  subdomain = "${var.subdomain}-api"

  tags = var.tags
}