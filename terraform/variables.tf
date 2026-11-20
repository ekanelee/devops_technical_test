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