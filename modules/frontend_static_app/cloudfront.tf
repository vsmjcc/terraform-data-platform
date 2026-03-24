resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.name}-oac"
  description                       = "OAC for ${local.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "static_assets" {
  count       = var.create_asset_cache_policy ? 1 : 0
  name        = "${var.name}-static-assets"
  default_ttl = var.asset_cache_default_ttl
  max_ttl     = var.asset_cache_max_ttl
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment != null ? var.comment : "Frontend ${local.domain_name}"
  default_root_object = var.default_root_object
  aliases             = [local.domain_name]
  price_class         = var.price_class
  wait_for_deployment = var.wait_for_deployment

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.origin_id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3_origin.id
  }

  ordered_cache_behavior {
    path_pattern             = "/assets/*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.origin_id
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = var.create_asset_cache_policy ? aws_cloudfront_cache_policy.static_assets[0].id : data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3_origin.id
  }

  dynamic "custom_error_response" {
    for_each = var.is_spa ? [403, 404] : []
    content {
      error_code            = custom_error_response.value
      response_code         = 200
      response_page_path    = "/${var.default_root_object}"
      error_caching_min_ttl = 0
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.common_tags
}
