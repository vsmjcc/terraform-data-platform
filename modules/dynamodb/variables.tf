variable "name" {
  type        = string
  description = "Nome da tabela DynamoDB"
}

variable "hash_key" {
  type        = string
  description = "Nome da partition key (HASH)"
}

variable "range_key" {
  type        = string
  description = "Nome da sort key (RANGE). null para não usar."
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string # "S" | "N" | "B"
  }))
  description = "Lista de atributos (normalmente: chaves e atributos usados em GSIs/LSIs)."
  default     = []
}

variable "billing_mode" {
  type        = string
  description = "PAY_PER_REQUEST ou PROVISIONED"
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode deve ser PAY_PER_REQUEST ou PROVISIONED."
  }
}

variable "read_capacity" {
  type        = number
  default     = 5
  description = "Usado apenas quando billing_mode = PROVISIONED"
}

variable "write_capacity" {
  type        = number
  default     = 5
  description = "Usado apenas quando billing_mode = PROVISIONED"
}

variable "ttl_attribute" {
  type        = string
  default     = null
  description = "Nome do atributo TTL (Number epoch seconds). null desabilita."
}

variable "enable_pitr" {
  type        = bool
  default     = true
  description = "Point-in-time recovery"
}

variable "enable_deletion_protection" {
  type        = bool
  default     = true
  description = "Deletion protection da tabela"
}

variable "table_class" {
  type        = string
  default     = "STANDARD"
  description = "STANDARD ou STANDARD_INFREQUENT_ACCESS"
  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class deve ser STANDARD ou STANDARD_INFREQUENT_ACCESS."
  }
}

variable "stream_enabled" {
  type        = bool
  default     = false
  description = "Habilita DynamoDB Streams"
}

variable "stream_view_type" {
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
  description = "Somente usado se stream_enabled = true"
  validation {
    condition = contains([
      "KEYS_ONLY",
      "NEW_IMAGE",
      "OLD_IMAGE",
      "NEW_AND_OLD_IMAGES"
    ], var.stream_view_type)
    error_message = "stream_view_type inválido."
  }
}

variable "gsi" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string # "ALL" | "KEYS_ONLY" | "INCLUDE"
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number) # somente PROVISIONED
    write_capacity     = optional(number) # somente PROVISIONED
  }))
  description = "Lista de GSIs (opcional)."
  default     = []
}

variable "autoscaling" {
  type = object({
    enabled         = bool
    min_read        = number
    max_read        = number
    min_write       = number
    max_write       = number
    target_read_pct = number
    target_write_pct = number
  })
  description = "Autoscaling só vale para PROVISIONED."
  default = {
    enabled          = false
    min_read         = 5
    max_read         = 200
    min_write        = 5
    max_write        = 200
    target_read_pct  = 70
    target_write_pct = 70
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
