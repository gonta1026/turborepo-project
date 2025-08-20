# ======================================
# API Module
# ======================================
# REST API用のCloud Run、Load Balancer、SSL証明書を管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project    = var.project_id
    managed_by = "terraform"
    module     = "api"
  })
}

# ======================================
# Random Resources
# ======================================

resource "random_password" "api_database_password" {
  length  = 32
  special = true
}

# ======================================
# API Database用Secret
# ======================================

resource "google_secret_manager_secret" "api_database_password" {
  secret_id = "api-database-password"

  labels = local.common_labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_database_password" {
  secret      = google_secret_manager_secret.api_database_password.id
  secret_data = random_password.api_database_password.result
}

# ======================================
# API Cloud SQLインスタンス
# ======================================

resource "google_sql_database_instance" "api_db_instance" {
  name             = "${var.project_id}-api-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_type         = "PD_SSD"
    disk_size         = var.db_disk_size

    backup_configuration {
      enabled                        = true
      start_time                     = "04:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [var.private_vpc_connection]
}

# ======================================
# API データベース
# ======================================

resource "google_sql_database" "api_database" {
  name      = var.database_name
  instance  = google_sql_database_instance.api_db_instance.name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

# ======================================
# API データベースユーザー
# ======================================

resource "google_sql_user" "api_user" {
  name     = var.database_user
  instance = google_sql_database_instance.api_db_instance.name
  password = random_password.api_database_password.result
}

# ======================================
# API Cloud Run用サービスアカウント
# ======================================

resource "google_service_account" "api_cloud_run_sa" {
  account_id   = "api-cloud-run-sa"
  display_name = "API Cloud Run Service Account"
  description  = "Service account for API Cloud Run service"
}

# ======================================
# API Cloud Run サービスアカウントの権限
# ======================================

resource "google_project_iam_member" "api_cloud_run_permissions" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.api_cloud_run_sa.email}"
}

# ======================================
# API Cloud Run Service
# ======================================

resource "google_cloud_run_v2_service" "api_service" {
  name     = "api-service"
  location = var.region

  template {
    service_account = google_service_account.api_cloud_run_sa.email

    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/api-service/api:latest"

      ports {
        container_port = var.container_port
      }

      env {
        name  = "PORT"
        value = tostring(var.container_port)
      }

      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.api_db_instance.private_ip_address
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.api_database.name
      }

      env {
        name  = "DB_USER"
        value = google_sql_user.api_user.name
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.api_database_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = var.cors_allowed_origins
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
        startup_cpu_boost = var.startup_cpu_boost
      }

      startup_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        initial_delay_seconds = var.startup_probe_initial_delay
        period_seconds        = var.startup_probe_period
        timeout_seconds       = var.startup_probe_timeout
        failure_threshold     = var.startup_probe_failure_threshold
      }

      liveness_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        period_seconds    = var.liveness_probe_period
        timeout_seconds   = var.liveness_probe_timeout
        failure_threshold = var.liveness_probe_failure_threshold
      }
    }

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }
  }

  labels = local.common_labels
}

# ======================================
# API Cloud Run Public Access
# ======================================

resource "google_cloud_run_v2_service_iam_member" "api_invoker" {
  location = google_cloud_run_v2_service.api_service.location
  name     = google_cloud_run_v2_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ======================================
# API Network Endpoint Group
# ======================================

resource "google_compute_region_network_endpoint_group" "api_neg" {
  name                  = "api-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.api_service.name
  }
}

# ======================================
# API Backend Service
# ======================================

resource "google_compute_backend_service" "api_backend_service" {
  name                  = "api-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.api_neg.id
  }

  log_config {
    enable = var.enable_backend_logging
  }
}

# ======================================
# API URL Map
# ======================================

resource "google_compute_url_map" "api_url_map" {
  name            = "api-url-map"
  default_service = google_compute_backend_service.api_backend_service.id

  dynamic "host_rule" {
    for_each = var.api_domain_name != "" ? [1] : []
    content {
      hosts        = [var.api_domain_name]
      path_matcher = "allpaths"
    }
  }

  dynamic "path_matcher" {
    for_each = var.api_domain_name != "" ? [1] : []
    content {
      name            = "allpaths"
      default_service = google_compute_backend_service.api_backend_service.id

      path_rule {
        paths   = ["/*"]
        service = google_compute_backend_service.api_backend_service.id
      }
    }
  }
}

# ======================================
# API SSL証明書
# ======================================

resource "google_certificate_manager_certificate" "api_cert" {
  count = var.api_domain_name != "" ? 1 : 0

  name        = "api-cert"
  description = "SSL certificate for API service"

  managed {
    domains = [var.api_domain_name]
  }

  labels = local.common_labels
}

# ======================================
# API 証明書マップエントリ
# ======================================

resource "google_certificate_manager_certificate_map_entry" "api_cert_entry" {
  count = var.api_domain_name != "" ? 1 : 0

  name         = "api-cert-entry"
  map          = var.shared_certificate_map_name
  certificates = [google_certificate_manager_certificate.api_cert[0].id]
  hostname     = var.api_domain_name
}

# ======================================
# API HTTPS Proxy
# ======================================

resource "google_compute_target_https_proxy" "api_https_proxy" {
  count = var.api_domain_name != "" ? 1 : 0

  name            = "api-https-proxy"
  url_map         = google_compute_url_map.api_url_map.id
  certificate_map = "//certificatemanager.googleapis.com/${var.shared_certificate_map_id}"

  depends_on = [
    google_certificate_manager_certificate_map_entry.api_cert_entry
  ]
}

# ======================================
# API HTTPS Forwarding Rule
# ======================================

resource "google_compute_global_forwarding_rule" "api_https_forwarding_rule" {
  count = var.api_domain_name != "" ? 1 : 0

  name       = "api-https-forwarding-rule"
  target     = google_compute_target_https_proxy.api_https_proxy[0].id
  port_range = "443"
  ip_address = var.api_static_ip_address
}

# ======================================
# API HTTP→HTTPSリダイレクト用 URL Map
# ======================================

resource "google_compute_url_map" "api_http_redirect" {
  count = var.api_domain_name != "" ? 1 : 0

  name = "api-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# ======================================
# API HTTP Proxy (リダイレクト用)
# ======================================

resource "google_compute_target_http_proxy" "api_http_proxy" {
  count = var.api_domain_name != "" ? 1 : 0

  name    = "api-http-proxy"
  url_map = google_compute_url_map.api_http_redirect[0].id
}

# ======================================
# API HTTP Forwarding Rule (リダイレクト用)
# ======================================

resource "google_compute_global_forwarding_rule" "api_http_forwarding_rule" {
  count = var.api_domain_name != "" ? 1 : 0

  name       = "api-http-forwarding-rule"
  target     = google_compute_target_http_proxy.api_http_proxy[0].id
  port_range = "80"
  ip_address = var.api_static_ip_address
}
