# Partial backend configuration: a backend block cannot use variables, 
# so bucket and prefix are supplied at init time with 
#   terraform init -backend-config=environments/<env>.backend.hcl 
terraform {
  backend "gcs" {}
}