# Bucket for static files (css, js, images), served through the load balancer. 
# Docs: https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket 
resource "google_storage_bucket" "static" { 
  name                        = "${var.project_id}-static-${var.environment}" # bucket names are global 
  location                    = var.region 
  uniform_bucket_level_access = true                     # IAM only, no per-object ACLs 
  force_destroy               = var.environment != "prod" # lets 'destroy' empty it in dev 
} 
 
# Public read: the load balancer's backend bucket serves objects anonymously. 
# If an org policy blocks allUsers, note it as a limitation in the README. 
resource "google_storage_bucket_iam_member" "static_public" { 
  bucket = google_storage_bucket.static.name 
  role   = "roles/storage.objectViewer" 
  member = "allUsers" 
} 