terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# キャッシュ用GCSバケット
# Turborepoのビルドキャッシュを保存するためのCloud Storageバケットを作成
# - uniform_bucket_level_access: IAMによる統一されたアクセス制御を有効化
# - force_destroy: Terraform destroy時にオブジェクトが残っていても削除可能
resource "google_storage_bucket" "turbo_cache" {
  name          = "${var.project_id}-turbo-cache"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    purpose    = "turborepo-cache"
    managed_by = "terraform"
  }
}

# Secret Managerシークレット（TURBO_TOKEN）
# キャッシュサーバーの認証トークンを安全に保存するためのSecret Managerシークレット
# - auto replication: 全リージョンで自動的にレプリケーション
# - 機密情報をTerraformファイルに直接書かずにdirenvで今回管理
resource "google_secret_manager_secret" "turbo_token" {
  secret_id = "turbo-token"

  labels = {
    purpose    = "turborepo-cache"
    managed_by = "terraform"
  }

  replication {
    auto {}
  }
}

# シークレットの実際の値を設定
# terraform.tfvarsのturbo_token変数（direnvで設定）から値を取得してSecret Managerに保存
resource "google_secret_manager_secret_version" "turbo_token" {
  secret      = google_secret_manager_secret.turbo_token.id
  secret_data = var.turbo_token
}

# Turbo Cache Server用のサービスアカウント
# Cloud Runサービスが使用する専用のサービスアカウントを作成
# - Cloud RunコンテナがGCSとSecret Managerにアクセスするために必要
# - 最小権限の原則に従い、必要なリソースのみにアクセス権限を付与
resource "google_service_account" "turbo_cache_service_account" {
  account_id   = "turbo-cache-server"
  display_name = "Turbo Cache Server Service Account"
  description  = "Service account for turborepo remote cache server"
}

# サービスアカウントにGCS権限付与
# GCSバケットに対してオブジェクトの読み書きを可能にする
resource "google_storage_bucket_iam_member" "turbo_cache_object_admin" {
  bucket = google_storage_bucket.turbo_cache.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.turbo_cache_service_account.email}"
}

# サービスアカウントにSecret Manager権限付与
# TURBO_TOKENシークレットの読み取りを可能にする
resource "google_secret_manager_secret_iam_member" "turbo_cache_secret_accessor" {
  secret_id = google_secret_manager_secret.turbo_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.turbo_cache_service_account.email}"
}

# Cloud Runサービス
# ducktors/turborepo-remote-cacheイメージを使用してキャッシュサーバーを作成
# - GCSをストレージとして使用
# - Secret ManagerからTURBO_TOKENを取得
# - 作成したサービスアカウントでGCPリソースにアクセス
resource "google_cloud_run_service" "turbo_cache_server" {
  name     = "turbo-cache-server"
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/service-account" = google_service_account.turbo_cache_service_account.email
      }
    }

    spec {
      service_account_name = google_service_account.turbo_cache_service_account.email
      containers {
        image = "ducktors/turborepo-remote-cache:2.6.1"

        ports {
          container_port = 3000
        }

        env {
          name  = "STORAGE_PROVIDER"
          value = "google-cloud-storage"
        }
        env {
          name  = "STORAGE_PATH"
          value = google_storage_bucket.turbo_cache.name
        }
        env {
          name  = "GCS_PROJECT_ID"
          value = var.project_id
        }
        # Application Default Credentials使用のため空白
        env {
          name  = "GCS_CLIENT_EMAIL"
          value = ""
        }
        env {
          name  = "GCS_PRIVATE_KEY"
          value = ""
        }
        env {
          name = "TURBO_TOKEN"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.turbo_token.secret_id
              key  = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Cloud Runサービスを公開
# インターネットからアクセス可能にする（認証はTURBO_TOKENで行う）
resource "google_cloud_run_service_iam_member" "turbo_cache_public" {
  service  = google_cloud_run_service.turbo_cache_server.name
  location = google_cloud_run_service.turbo_cache_server.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
