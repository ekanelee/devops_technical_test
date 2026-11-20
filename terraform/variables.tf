variable "project_id" {
  type        = string
  description = "GCP project that hosts this environment."
}

variable "environment" {
  type        = string
  description = "Environment name (dev or prod). Drives resource names."

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either dev or prod."
  }
}

variable "region" {
  type        = string
  description = "GCP region for all regional resources."
}

variable "registry_repo" {
  type        = string
  description = "Artifact Registry repository created by the bootstrap layer."
  default     = "app"
} 