
output "dns_zones" {
  description = "dns_zones"
  value = {
    for layer, mod in local.dns_modules : layer => {
      zone_id         = mod.zone_id
      zone_name       = mod.zone_name
      certificate_arn = mod.certificate_arn
    }
  }
}

