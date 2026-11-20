# Descriptions are avoided here to save time as they were already listed in previous commits
# before module refactoring.
variable "name"                    { type = string }
variable "region"                  { type = string }
variable "cloud_run_service_name"  { type = string }
variable "static_bucket_name"      { type = string }
variable "enable_https"            { type = bool }
variable "domain"                  { type = string }