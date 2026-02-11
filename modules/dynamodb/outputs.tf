output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  value       = aws_dynamodb_table.this.stream_arn
  description = "ARN do stream (se habilitado)"
}

output "hash_key" {
  value = var.hash_key
}

output "range_key" {
  value = var.range_key
}
