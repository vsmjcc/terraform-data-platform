variable "environment" {
  type = string
}

variable "bucket" {
  type = string
}

variable "database_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "quicksight_data_sources" {
  description = "Mapa de data sources do QuickSight já criados, por chave lógica (ex.: gold)"
  type = map(object({
    arn = string
  }))
  default = {}
}