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

module "cloud_run" {
  source = "./modules/cloud-run"

  name                = local.name
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  php_image           = local.php_image
  nginx_image         = local.nginx_image
  sql_connection_name = module.cloud_sql.connection_name
  db_name             = var.db_name
  db_user             = module.cloud_sql.db_user
  db_secret_id        = module.cloud_sql.secret_id
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  concurrency         = var.concurrency
  deletion_protection = var.deletion_protection
}

module "load_balancer" {
  source = "./modules/load-balancer"

  name                   = local.name
  region                 = var.region
  cloud_run_service_name = module.cloud_run.service_name
  static_bucket_name     = module.static_bucket.bucket_name
  enable_https           = var.enable_https
  domain                 = var.domain
}