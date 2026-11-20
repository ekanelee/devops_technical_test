# Dedicated identity for the running service: least privilege, one purpose. 
# Docs: https://cloud.google.com/iam/docs/best-practices-service-accounts 
resource "google_service_account" "runtime" { 
  account_id   = "${local.name}-run" 
  display_name = "Cloud Run runtime (${var.environment})" 
} 
 
# Needed to use the Cloud SQL connector. 
resource "google_project_iam_member" "runtime_sql_client" { 
  project = var.project_id 
  role    = "roles/cloudsql.client" 
  member  = "serviceAccount:${google_service_account.runtime.email}" 
} 
 
# Read only this one secret, not all secrets. 
resource "google_secret_manager_secret_iam_member" "runtime_db_password" { 
  secret_id = google_secret_manager_secret.db_password.secret_id 
  role      = "roles/secretmanager.secretAccessor" 
  member    = "serviceAccount:${google_service_account.runtime.email}" 
} 