output "repository_urls" {
  value = { for repo in aws_ecr_repository.this : repo.name => repo.repository_url }
}
