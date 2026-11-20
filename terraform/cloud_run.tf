# Dedicated identity for the running service: least privilege, one purpose. 
# Docs: https://cloud.google.com/iam/docs/best-practices-service-accounts 
resource "google_service_account" "runtime" {
  account_id   = "${local.name}-run"
  display_name = "Cloud Run runtime (${var.environment})"
}

# Needed to use the Cloud SQL connector. 
resource "google_project_iam_member" "runtime_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

# Read only this one secret, not all secrets. 
resource "google_secret_manager_secret_iam_member" "runtime_db_password" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}

# One Cloud Run service with two containers: nginx (ingress) + php-fpm (sidecar). 
# Docs: https://cloud.google.com/run/docs/deploying#sidecars 
resource "google_cloud_run_v2_service" "app" {
  name                = local.name
  location            = var.region
  deletion_protection = var.deletion_protection

  # Docs: https://cloud.google.com/run/docs/securing/ingress 
  # Only traffic arriving through the load balancer is accepted; 
  # the run.app URL is no longer reachable from the internet. 
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account                  = google_service_account.runtime.email
    max_instance_request_concurrency = var.concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Mounts a unix socket at /cloudsql/<connection-name> for the DB connection. 
    # Docs: https://cloud.google.com/sql/docs/mysql/connect-run 
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.main.connection_name]
      }
    }

    # Ingress container: the only one with a port. Starts after php-fpm. 
    containers {
      name       = "nginx"
      image      = local.nginx_image
      depends_on = ["php-fpm"]

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
        }
      }

      startup_probe {
        http_get {
          path = "/healthz"
        }
      }
    }

    # Sidecar: only this container talks to the database. 
    containers {
      name  = "php-fpm"
      image = local.php_image

      env {
        name  = "APP_ENV"
        value = var.environment
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.app.name
      }
      env {
        name  = "DB_SOCKET"
        value = "/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      # Password injected from Secret Manager at runtime. 
      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      startup_probe {
        tcp_socket {
          port = 9000
        }
      }
    }
  }

  # Make sure permissions and the secret exist before the first revision starts. 
  depends_on = [
    google_project_iam_member.runtime_sql_client,
    google_secret_manager_secret_iam_member.runtime_db_password,
    google_secret_manager_secret_version.db_password,
  ]
}

# Allow public invocation (the load balancer forwards anonymous requests). 
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.app.name
  location = google_cloud_run_v2_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}