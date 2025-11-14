locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "pritunl-vpn"
  }
}