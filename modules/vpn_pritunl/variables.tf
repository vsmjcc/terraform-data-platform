variable "ami_id" {
  description = "AMI ID para Ubuntu 22.04 (com SSM Agent)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet pública onde a instância será lançada"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc)"
  type        = string
}