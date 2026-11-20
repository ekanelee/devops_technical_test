output "tfstate_bucket" {
  description = "Name of the remote state bucket (goes in environments/<env>.backend.hcl)."
  value       = google_storage_bucket.tfstate.name
}

output "registry_url" {
  description = "Base URL for pushing images."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.registry_repo}"
}

output "wif_provider" {
  description = "Full provider name, goes in the GitHub secret WIF_PROVIDER."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "ci_service_account_email" {
  description = "CI service account, goes in the GitHub secret CI_SA_EMAIL."
  value       = google_service_account.ci.email
}