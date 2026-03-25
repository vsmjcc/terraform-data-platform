output "bucket_id" {
  description = "ID do bucket S3 do frontend."
  value       = aws_s3_bucket.site.id
}

output "bucket_name" {
  description = "Nome do bucket S3 do frontend."
  value       = aws_s3_bucket.site.bucket
}

output "bucket_arn" {
  description = "ARN do bucket S3 do frontend."
  value       = aws_s3_bucket.site.arn
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_arn" {
  description = "ARN da distribuição CloudFront."
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront_domain_name" {
  description = "Domínio gerado pelo CloudFront."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "site_domain_name" {
  description = "Domínio final da aplicação."
  value       = local.domain_name
}

output "site_url" {
  description = "URL HTTPS da aplicação."
  value       = "https://${local.domain_name}"
}
