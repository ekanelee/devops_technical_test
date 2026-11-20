locals {
  # APIs the whole project needs. 
  # Docs: https://cloud.google.com/apis/docs/getting-started 
  apis = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

# Enable every API in the list. 
# disable_on_destroy = false stops 'terraform destroy' from switching APIs off for the whole project. 
resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Remote state bucket used by the main Terraform configuration. 
# Docs: https://developer.hashicorp.com/terraform/language/backend/gcs 
resource "google_storage_bucket" "tfstate" {
  name                        = "${var.project_id}-tfstate"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  # Versioning lets you recover a previous state file after a mistake. 
  versioning {
    enabled = true
  }

  # Keep only the 10 most recent old versions so the bucket does not grow forever. 
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Protects against accidentally destroying your state. 
  lifecycle {
    prevent_destroy = true
  }
}

# Docker repository for the PHP-FPM and Nginx images. 
# Docs: https://cloud.google.com/artifact-registry/docs/repositories/create-repos 
resource "google_artifact_registry_repository" "app" {
  location      = var.region
  repository_id = var.registry_repo
  format        = "DOCKER"
  description   = "Container images for the PHP-FPM application"

  depends_on = [google_project_service.apis]
}