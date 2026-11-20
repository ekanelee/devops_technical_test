output "service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.app.name
}
output "url" {
  description = "run.app URL."
  value       = google_cloud_run_v2_service.app.uri
}