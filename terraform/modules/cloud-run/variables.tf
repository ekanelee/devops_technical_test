# Descriptions are avoided here to save time as they were already listed in previous commits
# before module refactoring.
variable "name"                { type = string }
variable "project_id"          { type = string }
variable "region"              { type = string }
variable "environment"         { type = string }
variable "php_image"           { type = string }
variable "nginx_image"         { type = string }
variable "sql_connection_name" { type = string }
variable "db_name"             { type = string }
variable "db_user"             { type = string }
variable "db_secret_id"        { type = string }
variable "min_instances"       { type = number }
variable "max_instances"       { type = number }
variable "concurrency"         { type = number }
variable "deletion_protection" { type = bool }