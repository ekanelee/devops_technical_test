output "connection_name" {
  description = "Instance connection name (project:region:instance)."
  value       = google_sql_database_instance.main.connection_name
}
output "db_user" {
  description = "Application database user."
  value       = google_sql_user.app.name
}
output "secret_id" {
  description = "Secret Manager id holding the DB password."
  value       = google_secret_manager_secret.db_password.secret_id
}