variable "vpc_cidr_block" {}
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "private_azs" {
  description = "Lista de AZs para subnets privadas"
  type        = list(string)
}

variable "public_azs" {
  description = "Lista de AZs para subnets públicas"
  type        = list(string)
}

variable "bucket_prefix" {
  description = "Prefixo dos buckets"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "ssh key name"
  type        = string
}

variable "peer_zerezes_account_id" {
  description = "id of zerezes account"
  type        = string
}

variable "peer_zerezes_vpc_id" {
  description = "vpc_id of zerezes account"
  type        = string
}

variable "peer_zerezes_vpc_cidr" {
  description = "cidr of zerezes account"
  type        = string
}

variable "public_zone_name" {
  description = "domain name"
  type        = string
}

