# ======================================
# Dashboard Module
# ======================================
# フロントエンドダッシュボード用のCloud Storage、CDN、Load Balancerを管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project    = var.project_id
    managed_by = "terraform"
    module     = "dashboard"
  })
}

# ======================================
# Random Resources
# ======================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ======================================
# Dashboard静的ウェブサイト用GCSバケット
# ======================================

resource "google_storage_bucket" "website_bucket" {
  name          = var.bucket_name != "" ? var.bucket_name : "terraform-gcp-466623-dashboard-frontend-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = var.force_destroy_bucket

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  labels = local.common_labels
}

# ======================================
# Dashboard バケットの公開読み取りアクセス
# ======================================

resource "google_storage_bucket_iam_member" "website_bucket_public_read" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ======================================
# Dashboard 静的IP
# ======================================

resource "google_compute_global_address" "website_ip" {
  name = "website-static-ip"
}

# ======================================
# Dashboard CDN Backend Bucket
# ======================================

resource "google_compute_backend_bucket" "website_backend" {
  name        = "website-backend"
  bucket_name = google_storage_bucket.website_bucket.name
  enable_cdn  = var.enable_cdn

  cdn_policy {
    cache_mode        = var.cdn_cache_mode
    default_ttl       = var.cdn_default_ttl
    client_ttl        = var.cdn_client_ttl
    max_ttl           = var.cdn_max_ttl
    negative_caching  = var.cdn_negative_caching
    serve_while_stale = var.cdn_serve_while_stale
  }
}

# ======================================
# Dashboard URL Map
# ======================================

resource "google_compute_url_map" "website_url_map" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website_backend.id

  dynamic "host_rule" {
    for_each = var.domain_name != "" ? [1] : []
    content {
      hosts        = [var.domain_name]
      path_matcher = "allpaths"
    }
  }

  dynamic "path_matcher" {
    for_each = var.domain_name != "" ? [1] : []
    content {
      name            = "allpaths"
      default_service = google_compute_backend_bucket.website_backend.id

      path_rule {
        paths   = ["/*"]
        service = google_compute_backend_bucket.website_backend.id
      }
    }
  }
}

# ======================================
# Dashboard HTTP Proxy
# ======================================

resource "google_compute_target_http_proxy" "website_http_proxy" {
  name    = "website-http-proxy"
  url_map = google_compute_url_map.website_url_map.id
}

# ======================================
# Dashboard HTTP Forwarding Rule
# ======================================

resource "google_compute_global_forwarding_rule" "website_http_forwarding_rule" {
  name       = "website-http-forwarding-rule"
  target     = google_compute_target_http_proxy.website_http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.website_ip.address
}

# ======================================
# Dashboard SSL証明書（カスタムドメイン用）
# ======================================

resource "google_certificate_manager_certificate" "website_cert" {
  count = var.domain_name != "" ? 1 : 0

  name        = "website-cert"
  description = "SSL certificate for dashboard website"

  managed {
    domains = [var.domain_name]
  }

  labels = local.common_labels
}

# ======================================
# Dashboard 証明書マップエントリ
# ======================================

resource "google_certificate_manager_certificate_map_entry" "website_cert_entry" {
  count = var.domain_name != "" ? 1 : 0

  name         = "website-cert-entry"
  map          = var.shared_certificate_map_name
  certificates = [google_certificate_manager_certificate.website_cert[0].id]
  hostname     = var.domain_name
}

# ======================================
# Dashboard HTTPS Proxy
# ======================================

resource "google_compute_target_https_proxy" "website_https_proxy" {
  count = var.domain_name != "" ? 1 : 0

  name            = "website-https-proxy"
  url_map         = google_compute_url_map.website_url_map.id
  certificate_map = "//certificatemanager.googleapis.com/${var.shared_certificate_map_id}"

  depends_on = [
    google_certificate_manager_certificate_map_entry.website_cert_entry
  ]
}

# ======================================
# Dashboard HTTPS Forwarding Rule
# ======================================

resource "google_compute_global_forwarding_rule" "website_https_forwarding_rule" {
  count = var.domain_name != "" ? 1 : 0

  name       = "website-https-forwarding-rule"
  target     = google_compute_target_https_proxy.website_https_proxy[0].id
  port_range = "443"
  ip_address = google_compute_global_address.website_ip.address
}