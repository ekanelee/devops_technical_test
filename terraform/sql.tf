# Cloud SQL names can't be reused for days after deletion, so add a random suffix. 
resource "random_id" "db_suffix" {
  byte_length = 3
}

# MySQL instance. 
# Docs: https://cloud.google.com/sql/docs/mysql/create-instance 
resource "google_sql_database_instance" "main" {
  name                = "${local.name}-db-${random_id.db_suffix.hex}"
  region              = var.region
  database_version    = "MYSQL_8_0"
  deletion_protection = var.deletion_protection # Terraform-level guard 

  settings {
    edition           = "ENTERPRISE" # required for the small shared-core tiers 
    tier              = var.db_tier
    availability_type = var.db_high_availability ? "REGIONAL" : "ZONAL"
    disk_size         = 10 # GB, the minimum 
    disk_autoresize   = true

    # Automated backups plus binary logs enable point-in-time recovery. 
    # Docs: https://cloud.google.com/sql/docs/mysql/backup-recovery/pitr 
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "02:00"
    }

    # Public IP, but no authorized networks, so the only way in is the Cloud SQL 
    # connector used by Cloud Run. Private IP is a planned hardening step. 
    # Docs: https://cloud.google.com/sql/docs/mysql/connect-run 
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

# The application database. 
resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}
# Random password: nobody types it, and it never appears in tfvars or in GitHub. 
# special = false avoids characters that complicate connection strings. 
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "google_sql_user" "app" {
  name     = "app"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}

# Store the password in Secret Manager; Cloud Run will read it from there. 
# Docs: https://cloud.google.com/run/docs/configuring/services/secrets 
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${local.name}-db-password"

  replication {
    auto {} # replicated automatically; use user_managed if data residency matters 
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}