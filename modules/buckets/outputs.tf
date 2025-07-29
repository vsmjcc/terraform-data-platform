output "buckets_info" {
  description = "Nome e ARN dos buckets por camada"
  value = {
    for layer, mod in local.bucket_modules : layer => {
      name = mod.bucket_name
      arn  = mod.bucket_arn
    }
  }
}

output "packages_bucket_name" {
  value = module.packages_bucket.bucket_name
}