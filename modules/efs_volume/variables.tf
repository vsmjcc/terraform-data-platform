variable "name" {
  description = "Nome do EFS (e usado como creation_token)"
  type        = string
}

variable "transition_to_ia" {
  description = "Quando mover para IA (infrequent access)"
  type        = string
  default     = "AFTER_7_DAYS"
}

variable "tags" {
  description = "Tags adicionais para o EFS"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnets privadas para criar o mount target"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups para o mount target (usado se create_security_group = false)"
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Se deve criar automaticamente o SG para o EFS"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC onde o SG será criado, necessário se create_security_group = true"
  type        = string
  default     = ""
}

variable "access_point_path" {
  description = "Diretório raiz do access point"
  type        = string
}

variable "access_point_uid" {
  description = "UID do access point (POSIX)"
  type        = number
  default     = 1000
}

variable "access_point_gid" {
  description = "GID do access point (POSIX)"
  type        = number
  default     = 1000
}
