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

      # Resource limits（学習用は控えめ、実際の本番では2CPU/4Gi以上推奨）
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
        value = "production"
      }
    }

    # Scaling configuration（本番環境用、最小インスタンス数を1に設定）
    scaling {
      min_instance_count = 1  # 本番では常時稼働
      max_instance_count = 20 # 本番負荷に対応
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

# 本番環境：パブリックアクセス許可（Load Balancer経由アクセス用）
resource "google_cloud_run_v2_service_iam_member" "api_service_public_access" {
  location = google_cloud_run_v2_service.api_service.location
  name     = google_cloud_run_v2_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# 本番環境：Load Balancerからのアクセスのみ許可（将来の制限用）
# 注意：Load Balancer設定完了後にこの設定を有効化してください
# resource "google_cloud_run_v2_service_iam_member" "api_service_lb_access" {
#   location = google_cloud_run_v2_service.api_service.location
#   name     = google_cloud_run_v2_service.api_service.name
#   role     = "roles/run.invoker"
#   member   = "serviceAccount:${google_service_account.load_balancer_sa.email}"
# }