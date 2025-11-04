

# module "glue_crawler_people_silver" {
#   source       = "../glue_crawler"
#   name         = "people-sheets-silver-crawler"
#   database_name = aws_glue_catalog_database.silver_people.name

#   s3_target_paths = [
#     "s3://${var.silver_bucket}/domain=people/source=gsheets/employees/",
#     "s3://${var.silver_bucket}/domain=people/source=gsheets/employees_invalid/",
#     "s3://${var.silver_bucket}/domain=people/source=gsheets/talent_employee_referrals/",
#     "s3://${var.silver_bucket}/domain=people/source=gsheets/talent_employee_referrals_invalid/",
#   ]

#   read_bucket_arns = ["arn:aws:s3:::${var.silver_bucket}"]
#   read_prefixes = [
#     "domain=people/source=gsheets/employees/*",
#     "domain=people/source=gsheets/employees_invalid/*",
#     "domain=people/source=gsheets/talent_employee_referrals/*",
#     "domain=people/source=gsheets/talent_employee_referrals_invalid/*",
#   ]

#   tags = merge(var.common_tags, { step = "bronze-to-silver" })
# }