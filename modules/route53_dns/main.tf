resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name
}

resource "aws_route53_record" "records" {
  for_each = { for r in var.records : r.name => r }

  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
