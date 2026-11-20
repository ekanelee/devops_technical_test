variable "name" {
  type        = string
  description = "Name prefix for the instance and the secret (e.g. app-dev)."
}
variable "region" {
  type        = string
  description = "Region of the instance."
}
variable "db_name" {
  type        = string
  description = "Database name."
}
variable "db_tier" {
  type        = string
  description = "Machine tier."
}
variable "db_high_availability" {
  type        = bool
  description = "Regional (HA) instance when true."
}
variable "deletion_protection" {
  type        = bool
  description = "Block deletion of the instance."
}