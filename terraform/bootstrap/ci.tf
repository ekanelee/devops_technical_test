# Identity that GitHub Actions impersonates. No keys are ever created for it.
# Docs: https://cloud.google.com/iam/docs/best-practices-service-accounts
resource "google_service_account" "ci" {
  account_id   = "github-ci"
  display_name = "GitHub Actions CI/CD"
}

# Roles Terraform needs to manage this stack. 
# resourcemanager.projectIamAdmin is powerful (Terraform grants cloudsql.client to the
# runtime service account).
locals {
  ci_roles = [
    "roles/run.admin",                       # Cloud Run service and its IAM
    "roles/cloudsql.admin",                  # Cloud SQL instance, database, user
    "roles/compute.loadBalancerAdmin",       # NEG, backends, URL map, proxies, certificate
    "roles/compute.networkAdmin",            # global static IP address
    "roles/storage.admin",                   # static bucket and the Terraform state bucket
    "roles/secretmanager.admin",             # DB password secret
    "roles/iam.serviceAccountAdmin",         # create the runtime service account
    "roles/iam.serviceAccountUser",          # let Cloud Run run as that service account
    "roles/resourcemanager.projectIamAdmin", # project-level role bindings
    "roles/artifactregistry.writer",         # push images
  ]
}

resource "google_project_iam_member" "ci" {
  for_each = toset(local.ci_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.ci.email}"
}

# Pool = the set of external identities we trust; provider = GitHub's OIDC issuer.
# Docs: https://cloud.google.com/iam/docs/workload-identity-federation
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Security-critical: only tokens issued for my repository are accepted.
  attribute_condition = "assertion.repository == \"${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allows identities from my repository to impersonate the CI service account.
resource "google_service_account_iam_member" "ci_wif" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}