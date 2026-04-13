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

# bronze
output "bronze_bucket_name" {
  value = module.bronze_bucket.bucket_name
}

output "bronze_bucket_arn" {
  value = module.bronze_bucket.bucket_arn
}

# silver
output "silver_bucket_name" {
  value = module.silver_bucket.bucket_name
}

output "silver_bucket_arn" {
  value = module.silver_bucket.bucket_arn
}

# gold
output "gold_bucket_name" {
  value = module.gold_bucket.bucket_name
}

output "gold_bucket_arn" {
  value = module.gold_bucket.bucket_arn
}

# data lake settings
output "data_lake_settings_bucket_arn" {
  value = module.data_lake_settings_bucket.bucket_arn
}

output "data_lake_settings_bucket_name" {
  value = module.data_lake_settings_bucket.bucket_name
}

# etls
output "etls_bucket_name" {
  value = module.etls_bucket.bucket_name
}

output "etls_bucket_arn" {
  value = module.etls_bucket.bucket_arn
}