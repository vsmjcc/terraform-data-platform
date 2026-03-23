variable "environment" {
  description = "Ambiente: dev ou prod"
  type        = string
}

variable "database_name" {
  type = string
}

variable "table_name" {
  type = string
}

variable "description" {
  type = string
}

variable "location" {
  type = string
}

variable "columns" {
  type = list(object({
    name    = string
    type    = string
    comment = optional(string)
  }))
}

variable "partition_keys" {
  # Suporta 0..N partições; cada uma pode ter projection opcional
  type = list(object({
    name    = string
    type    = string
    comment = optional(string)
    projection = optional(object({
      enabled       = optional(bool, true)
      type          = string           # ex.: "date", "enum", "integer"
      format        = optional(string) # ex.: "yyyy-MM-dd"
      range         = optional(string) # ex.: "2020-01-01,NOW" | "0,23"
      interval      = optional(string) # ex.: "1"
      interval_unit = optional(string) # ex.: "DAYS", "HOURS"
      values        = optional(string) # ex.: "us-east-1,us-west-2" (para enum)
    }))
  }))
  default = []
}

variable "parameters" {
  type    = map(string)
  default = { classification = "parquet", compressionType = "snappy" }
}

variable "input_format" {
  type    = string
  default = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
}

variable "output_format" {
  type    = string
  default = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
}

variable "serde_lib" {
  type    = string
  default = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
}

variable "quicksight" {
  description = "Config opcional para publicar a tabela como dataset no QuickSight"
  type = object({
    enabled         = optional(bool, false)
    data_source_key = optional(string)
    import_mode     = optional(string, "SPICE")
  })
  default = null
}

variable "quicksight_data_sources" {
  description = "Mapa de data sources do QuickSight já criados, por chave lógica (ex.: gold)"
  type = map(object({
    arn = string
  }))
  default = {}
}
