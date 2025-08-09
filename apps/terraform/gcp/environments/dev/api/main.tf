terraform {
  required_version = ">= 1.12.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Remote state reference to shared resources
data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/shared"
  }
}

# ======================================
# API Certificate Manager Resources
# ======================================
resource "google_certificate_manager_certificate" "api_cert" {
  name = "api-cert"


  location = "global"

  managed {
    domains = ["dev.api.my-learn-iac-sample.site"]
  }

  # Certificate Manager API有効化後に作成
  depends_on = [data.terraform_remote_state.shared]
}

# 共通Certificate MapにAPI用エントリーを追加
resource "google_certificate_manager_certificate_map_entry" "api_cert_map_entry" {
  name         = "api-cert-map-entry"
  map          = data.terraform_remote_state.shared.outputs.shared_certificate_map.name
  certificates = [google_certificate_manager_certificate.api_cert.id]
  hostname     = "dev.api.my-learn-iac-sample.site"
}

# ======================================
# HTTPS Load Balancer Configuration for Custom Domain
# ======================================

# Backend Service for Cloud Run
# Cloud RunサービスをHTTPS Load Balancerのバックエンドとして設定
# NEG (Network Endpoint Group) を使用してCloud Runサービスに接続
resource "google_compute_backend_service" "api_backend_service" {
  name        = "api-backend-service"
  description = "Backend service for API Cloud Run service"

  # Cloud Run用のバックエンド設定
  backend {
    group = google_compute_region_network_endpoint_group.api_neg.id
  }

  # Serverless NEG (Cloud Run) にはヘルスチェック不要

  # プロトコル設定
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  # ログ設定
  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# Network Endpoint Group (NEG) for Cloud Run
# Cloud RunサービスをLoad Balancerに接続するためのNEG
resource "google_compute_region_network_endpoint_group" "api_neg" {
  name                  = "api-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  description           = "NEG for API Cloud Run service"

  cloud_run {
    service = google_cloud_run_v2_service.api_service.name
  }
}

# Cloud Runはサーバーレスなので、ヘルスチェックは不要（自動的に管理される）

# URL Map for API Traffic Routing
# HTTPSリクエストをCloud RunのBackend Serviceにルーティング
resource "google_compute_url_map" "api_url_map" {
  name            = "api-url-map"
  default_service = google_compute_backend_service.api_backend_service.id
  description     = "URL map for API HTTPS load balancer"
}

# HTTP to HTTPS redirect URL Map for API
# HTTPアクセスを自動的にHTTPSにリダイレクト
resource "google_compute_url_map" "api_https_redirect" {
  name        = "api-https-redirect"
  description = "URL map to redirect HTTP to HTTPS for API"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# HTTPS Target Proxy for API
# HTTPS接続を処理し、共通Certificate Mapを使用してSSL証明書を適用
resource "google_compute_target_https_proxy" "api_https_proxy" {
  name    = "api-https-proxy"
  url_map = google_compute_url_map.api_url_map.id

  # 共通Certificate Mapを参照
  certificate_map = "//certificatemanager.googleapis.com/${data.terraform_remote_state.shared.outputs.shared_certificate_map.id}"
}

# HTTP Target Proxy for HTTPS redirect (API)
# HTTPアクセスをHTTPSにリダイレクト
resource "google_compute_target_http_proxy" "api_http_proxy" {
  name    = "api-http-proxy"
  url_map = google_compute_url_map.api_https_redirect.id
}

# HTTPS Forwarding Rule for API
# 静的IPアドレスでHTTPSリクエストを受け付けてTarget Proxyに転送
resource "google_compute_global_forwarding_rule" "api_https_forwarding_rule" {
  name        = "api-https-rule"
  target      = google_compute_target_https_proxy.api_https_proxy.id
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = data.terraform_remote_state.shared.outputs.api_static_ip_address
}

# HTTP Forwarding Rule for API (redirect to HTTPS)
# HTTPリクエストを受け付けてHTTPSにリダイレクト
resource "google_compute_global_forwarding_rule" "api_http_forwarding_rule" {
  name        = "api-http-rule"
  target      = google_compute_target_http_proxy.api_http_proxy.id
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address  = data.terraform_remote_state.shared.outputs.api_static_ip_address
}
