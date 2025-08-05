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

# Certificate Map for Certificate Manager
# 複数の証明書とドメインの関連付けを管理するためのマップを作成
# ロードバランサーが適切な証明書を選択できるようにする仕組み
# 将来的に複数ドメインや証明書を使用する場合の拡張性を提供
resource "google_certificate_manager_certificate_map" "dashboard_frontend" {
  name        = "dashboard-frontend-cert-map"
  description = "Certificate map for dashboard HTTPS"

  labels = {
    purpose    = "certificate-map"
    managed_by = "terraform"
  }

  depends_on = [data.google_project_service.certificate_manager_api]
}

# Certificate Map Entry
# 特定のドメイン名と証明書の具体的な関連付けを定義
# このエントリーにより、指定したドメインにアクセスした際に対応する証明書が使用される
# ホスト名ベースの証明書選択を実現する重要な設定
resource "google_certificate_manager_certificate_map_entry" "dashboard_frontend" {
  name         = "dashboard-frontend-cert-map-entry"
  map          = google_certificate_manager_certificate_map.dashboard_frontend.name
  certificates = [google_certificate_manager_certificate.dashboard_frontend.id]
  hostname     = var.domain_name
}

# ======================================
# HTTPS Load Balancer Configuration
# ======================================

# Global Static IP Address for Load Balancer
# HTTPSロードバランサー用のグローバル静的IPアドレスを取得
# ドメインのDNS設定でこのIPアドレスを指定することで、独自ドメインでアクセス可能になる
# 静的IPなのでLoad Balancerが再作成されてもIPアドレスが変わることがない
resource "google_compute_global_address" "dashboard_frontend" {
  name         = "dashboard-frontend-ip"
  description  = "Static IP for dashboard HTTPS load balancer"
  address_type = "EXTERNAL"
}

# HTTPS Target Proxy
# HTTPS（暗号化）接続を処理するためのプロキシを作成
# SSL/TLS証明書を使用してセキュアな通信を実現
# Certificate Managerで管理された証明書を使用してHTTPS接続を終端する
resource "google_compute_target_https_proxy" "dashboard_frontend" {
  name    = "dashboard-frontend-https-proxy"
  url_map = google_compute_url_map.dashboard_frontend.id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.dashboard_frontend.id}"
}

# HTTPS Forwarding Rule
# インターネットからのHTTPSリクエスト（ポート443）を受け付けるためのフォワーディングルールを作成
# 事前に取得した静的IPアドレスを使用して、一貫性のあるアクセスポイントを提供
# HTTPSプロキシと連携してセキュアな通信を実現し、本番運用に適した設定
resource "google_compute_global_forwarding_rule" "dashboard_frontend_https" {
  name        = "dashboard-frontend-https-rule"
  target      = google_compute_target_https_proxy.dashboard_frontend.id
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.dashboard_frontend.address
}

