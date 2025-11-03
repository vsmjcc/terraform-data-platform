variable "database_name" { 
  type = string 
}

variable "table_name"    { 
  type = string 
}

variable "description"   { 
  type = string 
}

variable "location"      { 
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
  type    = list(object({ name = string, type = string, comment = optional(string) }))
  default = []
}

variable "parameters" {
  type    = map(string)
  default = { classification = "parquet", compressionType = "snappy" }
}

variable "input_format"  { 
  type = string
  default = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat" 
}

variable "output_format" { 
  type = string
  default = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat" 
}

variable "serde_lib" {
  type    = string
  default = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
}
