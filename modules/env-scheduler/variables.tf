
variable "name_prefix" {
  description = "Prefix for created resources"
  type        = string
  default     = "env-scheduler"
}

variable "tag_key" {
  description = "Tag key used to select resources"
  type        = string
  default     = "Environment"
}

variable "tag_values" {
  description = "Tag values used to select resources"
  type        = list(string)
  default     = ["dev"]
}

variable "stop_cron_utc" {
  description = "EventBridge cron (UTC) for stopping resources"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "start_cron_utc" {
  description = "EventBridge cron (UTC) for starting resources"
  type        = string
  default     = "cron(0 11 * * ? *)"
}

variable "manage_ecs" {
  description = "Manage ECS services"
  type        = bool
  default     = true
}

variable "manage_asg" {
  description = "Manage Auto Scaling Groups"
  type        = bool
  default     = true
}

variable "manage_ec2" {
  description = "Manage EC2 instances"
  type        = bool
  default     = true
}

variable "manage_rds" {
  description = "Manage RDS instances"
  type        = bool
  default     = true
}

variable "ecs_desired_default_on_start" {
  description = "Fallback desired count for ECS services on start"
  type        = number
  default     = 1
}

variable "asg_default_on_start" {
  description = "Fallback ASG sizes on start"
  type        = object({ min = number, max = number, desired = number })
  default     = { min = 1, max = 1, desired = 1 }
}

variable "lambda_memory_mb" {
  description = "Lambda memory (MB)"
  type        = number
  default     = 256
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 900
}

variable "tags" {
  description = "Tags to add on created resources"
  type        = map(string)
  default     = {}
}
