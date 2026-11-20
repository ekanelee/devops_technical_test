# Global static IP: the address users (and scripts/get-ip.sh) will use. 
resource "google_compute_global_address" "lb" {
  name = "${local.name}-ip"
}

# Serverless NEG: how a load balancer points at Cloud Run. 
# Docs: https://cloud.google.com/load-balancing/docs/negs/serverless-neg-concepts 
resource "google_compute_region_network_endpoint_group" "run" {
  name                  = "${local.name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = module.cloud_run.service_name
  }
}

# Backend for dynamic requests: Cloud Run. 
resource "google_compute_backend_service" "app" {
  name                  = "${local.name}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.run.id
  }
}

# Backend for /static/*: the bucket, with Cloud CDN caching. 
# Docs: https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket 
resource "google_compute_backend_bucket" "static" {
  name        = "${local.name}-static"
  bucket_name = module.static_bucket.bucket_name
  enable_cdn  = true
}

# Routing: /static/* goes to the bucket, everything else to Cloud Run. 
# Bucket objects must be named static/... because the URL path is the object name. 
# Docs: https://cloud.google.com/load-balancing/docs/url-map-concepts 
resource "google_compute_url_map" "app" {
  name            = "${local.name}-urlmap"
  default_service = google_compute_backend_service.app.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "main"
  }

  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.app.id

    path_rule {
      paths   = ["/static/*"]
      service = google_compute_backend_bucket.static.id
    }
  }
}

# HTTP listener on port 80. 
resource "google_compute_target_http_proxy" "http" {
  name    = "${local.name}-http-proxy"
  url_map = google_compute_url_map.app.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${local.name}-http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.lb.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.http.id
}

# HTTPS listener, created only when enable_https = true (needs a domain). 
# Docs: https://cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs 
resource "google_compute_managed_ssl_certificate" "app" {
  count = var.enable_https ? 1 : 0
  name  = "${local.name}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_target_https_proxy" "https" {
  count            = var.enable_https ? 1 : 0
  name             = "${local.name}-https-proxy"
  url_map          = google_compute_url_map.app.id
  ssl_certificates = [google_compute_managed_ssl_certificate.app[0].id]
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.enable_https ? 1 : 0
  name                  = "${local.name}-https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.lb.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.https[0].id

} 