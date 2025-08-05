# Dashboard Infrastructure Configuration

# ======================================
# Cloud Storage Configuration
# ======================================

# Cloud Storageバケット（静的ウェブサイトホスティング）
resource "google_storage_bucket" "dashboard_frontend" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = false # 誤った削除を防ぐ

  # 静的ウェブサイトホスティング用の設定
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # セキュリティ設定
  public_access_prevention    = "inherited"
  uniform_bucket_level_access = true

  # ラベル設定
  labels = {
    purpose    = "dashboard-frontend"
    managed_by = "terraform"
  }
}

# バケットをパブリックに設定
resource "google_storage_bucket_iam_member" "dashboard_frontend_public" {
  bucket = google_storage_bucket.dashboard_frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# CDNバックエンドバケット
resource "google_compute_backend_bucket" "dashboard_frontend" {
  name        = "dashboard-frontend-backend"
  description = "Dashboard Frontend Backend Bucket"
  bucket_name = google_storage_bucket.dashboard_frontend.name
  enable_cdn  = true

  # キャッシュポリシー
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = var.cdn_cache_ttl
    default_ttl       = var.cdn_cache_ttl
    max_ttl           = var.cdn_cache_ttl * 2 # 最大TTLは通常の2倍
    negative_caching  = true
    serve_while_stale = 86400 # 24時間
  }
}

# URLマップ
resource "google_compute_url_map" "dashboard_frontend" {
  name            = "dashboard-frontend-url-map"
  description     = "Dashboard Frontend URL Map"
  default_service = google_compute_backend_bucket.dashboard_frontend.self_link

  # ホストルール
  host_rule {
    hosts        = [var.domain_name]
    path_matcher = "dashboard-frontend-paths"
  }

  # パスマッチャー
  path_matcher {
    name            = "dashboard-frontend-paths"
    default_service = google_compute_backend_bucket.dashboard_frontend.self_link
  }
}

# ======================================
# Data Sources for Shared Resources
# ======================================

# Reference to Certificate Manager API enabled in shared module
data "google_project_service" "certificate_manager_api" {
  service = "certificatemanager.googleapis.com"
}


# Certificate Manager Certificate
# 指定したドメイン名用のSSL/TLS証明書をGoogleが自動で取得・管理
# Let's Encryptなどの認証局から有効な証明書を取得し、自動更新も行う
# HTTPS通信を可能にするために必要で、ブラウザに「安全な接続」として表示される
resource "google_certificate_manager_certificate" "dashboard_frontend" {
  name     = "dashboard-frontend-cert"
  location = "global"

  managed {
    domains = [var.domain_name]
  }

  labels = {
    purpose    = "https-certificate"
    managed_by = "terraform"
  }

  depends_on = [data.google_project_service.certificate_manager_api]
}

