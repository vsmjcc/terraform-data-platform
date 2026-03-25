module "dns_data_zerezes" {
  source      = "../route53_dns"
  zone_name   = "data.${var.public_zone_name}"
  create_zone = true
  create_cert = true
  records     = []
}

# module "dns_zerezes" {
#   source      = "../route53_dns"
#   zone_name   = var.public_zone_name
#   create_zone = true

#   records = [
#     {
#       name    = "data"
#       type    = "NS"
#       ttl     = 300
#       records = module.dns_data_zerezes.name_servers
#     }
#   ]
# }

module "cert_data_zerezes" {
  source      = "../cert_wildcard"
  domain_name = "data.${var.public_zone_name}"
  zone_id     = module.dns_data_zerezes.zone_id
}

locals {
  dns_modules = {
    data_zerezes = merge(
      module.dns_data_zerezes,
      module.cert_data_zerezes
    )
  }
}
