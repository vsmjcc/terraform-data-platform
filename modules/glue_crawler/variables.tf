variable "name" {
  type = string # ex: "shopify_silver"
}

variable "database_name" {
  type = string
}

variable "s3_target_paths" {
  type = list(string) # ex: ["s3://bucket/prefix1/", "s3://bucket/prefix2/"]
}

# IAM/S3
variable "read_bucket_arns" {
  type = list(string) # ex: ["arn:aws:s3:::zrzs-${var.environment}-data-lake-silver"]
}

variable "read_prefixes" {
  type = list(string) # ex: ["domain=commerce/source=shopify/dataset=customers/*", ...]
}

# Comportamento do crawler
variable "recrawl_behavior" {
  type    = string
  default = "CRAWL_EVERYTHING" # ou "CRAWL_NEW_FOLDERS_ONLY"
}

variable "update_behavior" {
  type    = string
  default = "UPDATE_IN_DATABASE"
}

variable "delete_behavior" {
  type    = string
  default = "LOG"
}

# Schedule (cron de Glue). Se vazio, não agenda.
variable "schedule" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
