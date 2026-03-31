variable "environment" {
  type = string
}

variable "database_name" {
  type = string
}

variable "view_name" {
  type = string
}

variable "sql" {
  description = "SQL da view sem o CREATE VIEW. Apenas o SELECT ..."
  type        = string
}

variable "data_catalog" {
  type    = string
  default = "AwsDataCatalog"
}

variable "athena_workgroup" {
  type    = string
  default = "primary"
}

variable "athena_output_location" {
  type = string
}

variable "columns" {
  type = list(object({
    name            = string
    type            = optional(string)
    quicksight_type = optional(string)
  }))
  default = []
}

variable "quicksight" {
  type = object({
    enabled                 = bool
    data_source_key         = string
    import_mode             = optional(string, "SPICE")
    create_refresh_schedule = optional(bool, false)
    start_after_date_time   = optional(string)
    schedule_id             = optional(string, "daily")
    refresh_interval        = optional(string, "DAILY")
    refresh_type            = optional(string, "FULL_REFRESH")
  })
  default = null
}

variable "quicksight_data_sources" {
  type = map(object({
    arn = string
  }))
  default = {}
}