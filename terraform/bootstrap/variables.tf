variable "project_id" {
  type        = string
  description = "Existing GCP project that will host the application."
}

variable "region" {
  type        = string
  description = "Region for the state bucket and the Artifact Registry repository."
  default     = "europe-west1"
}

variable "registry_repo" {
  type        = string
  description = "Name of the Artifact Registry Docker repository."
  default     = "app"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository allowed to deploy, as owner/name (case-sensitive)."
}