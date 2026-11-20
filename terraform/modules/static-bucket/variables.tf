variable "bucket_name" {
  type        = string
  description = "Globally unique bucket name."
}
variable "location" {
  type        = string
  description = "Bucket location (region)."
}
variable "force_destroy" {
  type        = bool
  description = "Allow deleting a bucket that still contains objects (dev only)."
}