terraform {
  required_version = ">= 1.12.2"
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

# ======================================
# Cloud Storage for Static Website
# ======================================

# Cloud Storage bucket for static website hosting
resource "google_storage_bucket" "website_bucket" {
  name     = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-dashboard"
  location = var.region

  # 静的ウェブサイトホスティング用の設定
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # パブリックアクセス用の設定
  uniform_bucket_level_access = true

  # パブリックアクセス防止を無効化（静的サイト用）
  public_access_prevention = "inherited"

  labels = merge(
    {
      managed_by = "terraform"
      purpose    = "static-website"
    },
    var.labels
  )
}

# バケットをパブリックに設定
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ======================================
# CDN Backend Bucket Configuration
# ======================================

# Backend bucket for Cloud CDN
resource "google_compute_backend_bucket" "website_backend" {
  name        = "${var.project_id}-dashboard-backend"
  bucket_name = google_storage_bucket.website_bucket.name
  description = "Backend bucket for dashboard static website CDN"

  # CDN設定
  enable_cdn = true

  cdn_policy {
    # キャッシュモード設定
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600  # 1時間
    max_ttl           = 86400 # 24時間
    client_ttl        = 3600  # 1時間
    negative_caching  = true
    serve_while_stale = 86400 # 24時間
  }
}

# ======================================
# HTTPS Load Balancer Configuration
# ======================================

# URL Map for routing
resource "google_compute_url_map" "website_url_map" {
  name            = "${var.project_id}-dashboard-url-map"
  default_service = google_compute_backend_bucket.website_backend.id
  description     = "URL map for dashboard static website"
  # シンプルな設定でまず動作確認
  # デフォルトですべてのトラフィックをbackend bucketに転送
}

# 一時的なHTTP Target Proxy（後でHTTPSに置き換え）
resource "google_compute_target_http_proxy" "website_http_proxy" {
  name    = "${var.project_id}-dashboard-http-proxy"
  url_map = google_compute_url_map.website_url_map.id
}

# HTTP Forwarding Rule
resource "google_compute_global_forwarding_rule" "website_http_forwarding_rule" {
  name        = "${var.project_id}-dashboard-http-rule"
  target      = google_compute_target_http_proxy.website_http_proxy.id
  port_range  = "80"
  ip_protocol = "TCP"
}
