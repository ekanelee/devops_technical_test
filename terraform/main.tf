module "cloud_sql" {
  source = "./modules/cloud-sql"

  name                 = local.name
  region               = var.region
  db_name              = var.db_name
  db_tier              = var.db_tier
  db_high_availability = var.db_high_availability
  deletion_protection  = var.deletion_protection
}

module "static_bucket" {
  source = "./modules/static-bucket"

  bucket_name   = "${var.project_id}-static-${var.environment}"
  location      = var.region
  force_destroy = var.environment != "prod"
}