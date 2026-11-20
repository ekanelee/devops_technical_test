output "lb_ip_address" {
  description = "Global static IP of the load balancer: the application's public IP."
  value       = google_compute_global_address.lb.address
}

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

output "app_url" {
  description = "URL to open in the browser."
  value       = var.enable_https && var.domain != "" ? "https://${var.domain}" : "http://${google_compute_global_address.lb.address}"
}