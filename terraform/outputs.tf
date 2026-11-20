output "cloud_run_url" {
  description = "run.app URL of the service (unreachable from the internet once ingress is LB-only)."
  value       = module.cloud_run.url
}

output "static_bucket_name" {
  description = "Bucket that holds the static files (upload under static/)."
  value       = module.static_bucket.bucket_name
}

output "sql_connection_name" {
  description = "Cloud SQL instance connection name (project:region:instance)."
  value       = module.cloud_sql.connection_name
}

