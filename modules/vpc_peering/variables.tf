variable "requester_vpc_id" {
  description = "VPC ID na conta requester (zerezes-data-dev)"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "CIDR do VPC requester"
  type        = string
}

variable "peer_vpc_id" {
  description = "VPC ID na conta peer (zerezes)"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR do VPC peer"
  type        = string
}

variable "peer_account_id" {
  description = "AWS Account ID da conta peer (zerezes)"
  type        = string
}

variable "requester_private_route_table_ids" {
  description = "Route Tables privadas (lista) no requester para receber rota ao peer"
  type        = list(string)
}

variable "peer_private_route_table_ids" {
  description = "Route Tables privadas (lista) no peer para receber rota ao requester (usado no modo gerenciado)"
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Porta do DB (5432/3306 etc) — usada na regra SG opcional"
  type        = number
  default     = 5432
}

variable "requester_app_sg_id" {
  description = "Security Group da app/cliente no requester (opcional, para SG->SG)"
  type        = string
  default     = null
}

variable "peer_rds_sg_id" {
  description = "Security Group do RDS no peer (opcional, para SG->SG ou CIDR)"
  type        = string
  default     = null
}

variable "manage_peer_side" {
  description = "Se true, o módulo também aceita o peering e cria rotas/DNS no peer (exige provider/role do peer)."
  type        = bool
  default     = false
}

variable "name" {
  description = "Tag Name base"
  type        = string
  default     = "vpc-peering"
}
