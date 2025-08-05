# Dashboard Infrastructure Configuration

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
    purpose     = "dashboard-frontend"
    environment = "production"
    managed_by  = "terraform"
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
