locals {
  origin_id   = "s3-${var.name}"
  domain_name = var.subdomain == null || var.subdomain == "" ? var.zone_name : "${var.subdomain}.${var.zone_name}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "frontend_static_site"
    },
    var.tags
  )
}
