output "tfstate_bucket" {
  description = "Name of the remote state bucket (goes in environments/<env>.backend.hcl)."
  value       = google_storage_bucket.tfstate.name
}

output "registry_url" {
  description = "Base URL for pushing images."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.registry_repo}"
} 