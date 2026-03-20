variable "namespace" {
  description = "QuickSight namespace"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name used in folder IDs"
  type        = string
}

variable "admin_group_names" {
  description = "Existing QuickSight/IAM Identity Center group names"
  type        = list(string)
  default     = []
}

variable "areas" {
  description = "Top-level folders and existing group names"
  type = map(object({
    display_name = string
    group_name   = string
  }))

  validation {
    condition = alltrue([
      for _, area in var.areas :
      trimspace(area.group_name) != ""
    ])
    error_message = "Each area must define group_name."
  }
}