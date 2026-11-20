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
variable "db_name" {
  type        = string
  description = "Name of the application database inside the Cloud SQL instance."
}

variable "db_tier" {
  type        = string
  description = "Cloud SQL machine tier, e.g. db-f1-micro for dev."
}

variable "db_high_availability" {
  type        = bool
  description = "true = regional (HA) instance, false = single zone."
}

variable "deletion_protection" {
  type        = bool
  description = "Blocks accidental deletion of the database and Cloud Run service. false only in dev."
}
variable "image_tag" {
  type        = string
  description = "Tag of the images to deploy (Git SHA). Supplied at run time, not in tfvars."
}

variable "min_instances" {
  type        = number
  description = "Minimum Cloud Run instances. 0 saves money but causes cold starts."
}

variable "max_instances" {
  type        = number
  description = "Maximum Cloud Run instances, a cost safety limit."
}

variable "concurrency" {
  type        = number
  description = "Concurrent requests per instance. Keep close to pm.max_children in the PHP-FPM pool."
}

variable "enable_https" {
  type        = bool
  description = "Create a Google-managed certificate and HTTPS listener. Requires a domain."
}

variable "domain" {
  type        = string
  description = "Domain pointing at the load balancer IP. Leave empty when enable_https is false."
} 