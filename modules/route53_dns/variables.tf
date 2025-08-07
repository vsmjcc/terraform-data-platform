variable "zone_name" {
  description = "Nome da zona DNS"
  type        = string
}

variable "create_zone" {
  description = "Se a zona deve ser criada (true) ou apenas usada (false)"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "ID da zona DNS (necessário se create_zone = false)"
  type        = string
  default     = ""
}

variable "create_cert" {
  description = "cria certificado tls"
  type        = bool
  default     = false
}

variable "records" {
  description = "Lista de registros DNS"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}
