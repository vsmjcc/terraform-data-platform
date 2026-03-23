variable "environment" {
  type = string
}

# Buckets (sem ARN)
variable "bronze_bucket" {
  type = string # ex: "zrzs-dev-data-lake-bronze"
}

variable "silver_bucket" {
  type = string # ex: "zrzs-dev-data-lake-silver"
}

variable "gold_bucket" {
  type = string # ex: "zrzs-dev-data-lake-gold"
}

variable "etls_bucket" {
  type = string # ex: "zrzs-dev-etls"
}

variable "quicksight_data_sources" {
  description = "Mapa de data sources do QuickSight já criados, por chave lógica (ex.: gold)"
  type = map(object({
    arn = string
  }))
  default = {}
}

