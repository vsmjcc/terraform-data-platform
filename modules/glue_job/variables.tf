variable "project" {
  type = string
}

variable "name" {
  type = string
}

variable "script_bucket" {
  type = string
}

variable "script_key" {
  type = string
}

variable "upload_script" {
  type    = bool
  default = false
}

variable "script_local_path" {
  type    = string
  default = "sample.py"
}

variable "script_sse" {
  type    = string
  default = null # "AES256" | "aws:kms"
}

variable "script_sse_kms_id" {
  type    = string
  default = null
}

variable "temp_bucket" {
  type = string
}

variable "temp_prefix" {
  type    = string
  default = "glue/tmp/" # termina com "/"
}

variable "data_buckets" {
  type        = list(string)
  description = "Buckets do data lake que o Glue deve acessar"
}

variable "kms_keys" {
  type        = list(string)
  default     = []
  description = "ARNs de chaves KMS usadas nos buckets (opcional)"
}

variable "glue_version" {
  type    = string
  default = "4.0"
}

variable "worker_type" {
  type    = string
  default = "G.1X" # G.2X / G.4X / G.8X...
}

variable "number_of_workers" {
  type    = number
  default = 2
}

variable "execution_class" {
  type    = string
  default = "STANDARD" # ou "FLEX"
}

variable "max_retries" {
  type    = number
  default = 0
}

variable "default_arguments" {
  type    = map(string)
  default = {}
}

variable "use_vpc" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets privadas para o Glue (se usar VPC)"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security Groups para o Glue (se usar VPC)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
