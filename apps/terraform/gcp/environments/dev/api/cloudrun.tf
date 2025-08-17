# ======================================
# Cloud Run Service - VPC統合・セキュア構成
# ======================================
# GoアプリケーションAPIサーバーをCloud Runで実行
# プライベートVPCに統合し、Cloud SQLと安全に通信

# Cloud Run Service
resource "google_cloud_run_v2_service" "api_service" {
  name     = "api-service"
  location = var.region

  template {
    # Service account for Cloud Run
    service_account = google_service_account.api_cloud_run_sa.email

    # VPC統合設定
    vpc_access {
      connector = data.terraform_remote_state.shared.outputs.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    # Container configuration
    containers {
      image = "gcr.io/${var.project_id}/api-service:latest"

      ports {
        container_port = 8080
      }

      # Resource limits
      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
        cpu_idle = true
      }

      # Environment variables
      env {
        name  = "GIN_MODE"
        value = "release"
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
        value = var.database_name
      }

      env {
        name  = "DB_USER"
        value = var.database_user
      }

      # Secret Manager からパスワード取得
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_SSLMODE"
        value = "require"
      }

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "DASHBOARD_CLIENT_URL"
        value = var.dashboard_client_url
      }

      env {
        name  = "ENVIRONMENT"
        value = "development"
      }
    }

    # Scaling configuration
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  # Custom domain mapping (if specified)
  dynamic "traffic" {
    for_each = var.api_domain_name != "" ? [1] : []
    content {
      percent = 100
      type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    }
  }

  labels = var.labels

  # 依存関係
  depends_on = [
    google_sql_database_instance.api_db_instance,
    google_secret_manager_secret_version.db_password
  ]
}

# ======================================
# Service Account for Cloud Run
# ======================================

# Cloud Run用のサービスアカウント
resource "google_service_account" "api_cloud_run_sa" {
  account_id   = "api-cloud-run-sa"
  display_name = "API Cloud Run Service Account"
  description  = "Service account used by Cloud Run API service"
}

# Secret Manager読み取り権限
resource "google_project_iam_member" "api_cloud_run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.api_cloud_run_sa.email}"
}

# Cloud SQL接続権限
resource "google_project_iam_member" "api_cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.api_cloud_run_sa.email}"
}

# ======================================
# IAM Policies
# ======================================

# 開発環境：パブリックアクセス許可（本番環境では制限すること）
resource "google_cloud_run_v2_service_iam_member" "api_service_public_access" {
  location = google_cloud_run_v2_service.api_service.location
  name     = google_cloud_run_v2_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ======================================
# Custom Domain Mapping (Optional)
# ======================================

# Custom domain mapping (if domain name is provided)
# resource "google_cloud_run_domain_mapping" "api_domain" {
#   location = var.region
#   name     = var.api_domain_name
#   metadata {
#     namespace = var.project_id
#   }

#   spec {
#     route_name = google_cloud_run_v2_service.api_service.name
#   }
# }
