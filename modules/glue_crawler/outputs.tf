output "role_arn" {
  value = aws_iam_role.this.arn
}

output "crawler_name" {
  value = aws_glue_crawler.this.name
}