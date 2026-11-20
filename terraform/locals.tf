locals {
  # Every resource name starts with this. scripts/get-ip.sh relies on app-<env> and app-<env>-ip. 
  name = "app-${var.environment}"

  # Base path for container images (image names and tags are added later). 
  registry    = "${var.region}-docker.pkg.dev/${var.project_id}/${var.registry_repo}"
  php_image   = "${local.registry}/php-fpm:${var.image_tag}"
  nginx_image = "${local.registry}/nginx:${var.image_tag}"
} 