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

# Remote state reference to shared resources
data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/shared"
  }
}


# ======================================
# Cloud Storage for Static Website
# ======================================

# Cloud Storage bucket for static website hosting
# React.jsで作成したダッシュボードアプリケーションのビルド成果物を格納するためのバケットを作成
# index.htmlをメインページとして設定し、404エラー時の専用ページも指定
# インターネット経由でアクセス可能な静的Webサイトとして公開する
resource "google_storage_bucket" "website_bucket" {
  name     = var.bucket_name
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
    var.labels,
    {
      purpose = "static-website"
    },
  )
}

# バケットをパブリックに設定
# 作成したストレージバケット内のファイルを全てのユーザーが閲覧できるように権限を設定
# これにより、インターネット上の誰でもWebサイトにアクセスできるようになる
# storage.objectViewerロールでファイルの読み取り専用アクセスを許可
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ======================================
# CDN Backend Bucket Configuration
# ======================================

# Backend bucket for Cloud CDN
# Cloud StorageバケットをCDN（Content Delivery Network）のバックエンドとして設定
# 世界中のエッジサーバーにコンテンツをキャッシュして高速配信を実現
# 静的ファイル（HTML、CSS、JS、画像など）を効率的に配信し、ユーザー体験を向上させる
resource "google_compute_backend_bucket" "website_backend" {
  name        = "dashboard-backend"
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
# ロードバランサーでのトラフィック振り分けルールを定義
# 全てのHTTP/HTTPSリクエストをCloud Storageバケットに転送する設定
# パスベースやホストベースの詳細なルーティングルールの基盤となる
resource "google_compute_url_map" "website_url_map" {
  name            = "dashboard-url-map"
  default_service = google_compute_backend_bucket.website_backend.id
  description     = "URL map for dashboard static website"
  # シンプルな設定でまず動作確認
  # デフォルトですべてのトラフィックをbackend bucketに転送
}

# HTTP to HTTPS redirect URL Map
# HTTPアクセスを自動的にHTTPSにリダイレクトするための専用URLマップ
# セキュアな接続を強制し、ユーザーが間違ってHTTPでアクセスしてもHTTPSに誘導
resource "google_compute_url_map" "https_redirect" {
  name        = "dashboard-https-redirect"
  description = "URL map to redirect HTTP to HTTPS"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# HTTP Target Proxy for HTTPS redirect
# HTTP（非暗号化）接続を処理してHTTPSにリダイレクトするためのプロキシを作成
# すべてのHTTPリクエストを自動的にHTTPSにリダイレクトしてセキュアな接続を強制
# リダイレクト専用のURLマップを使用してHTTPS URLに301リダイレクト
resource "google_compute_target_http_proxy" "website_http_proxy" {
  name    = "dashboard-http-proxy"
  url_map = google_compute_url_map.https_redirect.id # リダイレクトを無効化
}

# HTTP Forwarding Rule
# インターネットからのHTTPリクエスト（ポート80）を受け付けるためのフォワーディングルールを作成
# グローバルに配置され、世界中からのアクセスを受け付ける
# HTTPプロキシに接続してリクエストを処理させる（後にHTTPSに置き換え予定）
resource "google_compute_global_forwarding_rule" "website_http_forwarding_rule" {
  name        = "dashboard-http-rule"
  target      = google_compute_target_http_proxy.website_http_proxy.id
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.website_ip.address
}

# ======================================
# HTTPS Configuration with Certificate Manager
# ======================================

# Global Static IP Address for Load Balancer
# HTTPSロードバランサー用のグローバル静的IPアドレスを取得
# ドメインのDNS設定でこのIPアドレスを指定することで、独自ドメインでアクセス可能になる
# 静的IPなのでサーバー再起動などでIPアドレスが変わることがない
resource "google_compute_global_address" "website_ip" {
  name         = "dashboard-ip"
  description  = "Static IP for dashboard HTTPS load balancer"
  address_type = "EXTERNAL"
  # IPアドレスは自動的に割り当てられます
}

# Certificate Manager Certificate (Google-managed)
# 指定したドメイン名用のSSL/TLS証明書をGoogleが自動で取得・管理
# Let's Encryptなどの認証局から有効な証明書を取得し、自動更新も行う
# HTTPS通信を可能にするために必要で、ブラウザに「安全な接続」として表示される
resource "google_certificate_manager_certificate" "website_cert" {
  name     = "dashboard-cert"
  location = "global"

  managed {
    domains = [var.domain_name]
  }

  labels = merge(
    var.labels,
    {
      purpose = "https-certificate"
    },
  )

  # Certificate Manager API有効化後に作成 (shared/apis.tf)
  # 依存: google_project_service.certificate_manager_api
  depends_on = [data.terraform_remote_state.shared]
}

# Certificate Map for Certificate Manager
# 複数の証明書とドメインの関連付けを管理するためのマップを作成
# ロードバランサーが適切な証明書を選択できるようにする仕組み
# 将来的に複数ドメインや証明書を使用する場合の拡張性を提供
resource "google_certificate_manager_certificate_map" "website_cert_map" {
  name        = "dashboard-cert-map"
  description = "Certificate map for dashboard HTTPS"

  labels = merge(
    var.labels,
    {
      purpose = "certificate-map"
    },
  )

  # Certificate Manager API有効化後に作成 (shared/apis.tf)
  # 依存: google_project_service.certificate_manager_api
  depends_on = [data.terraform_remote_state.shared]
}

# Certificate Map Entry
# 特定のドメイン名と証明書の具体的な関連付けを定義
# このエントリーにより、指定したドメインにアクセスした際に対応する証明書が使用される
# ホスト名ベースの証明書選択を実現する重要な設定
resource "google_certificate_manager_certificate_map_entry" "website_cert_map_entry" {
  name         = "dashboard-cert-map-entry"
  map          = google_certificate_manager_certificate_map.website_cert_map.name
  certificates = [google_certificate_manager_certificate.website_cert.id]
  hostname     = var.domain_name
}

# ======================================
# IAM Service Account for GitHub Actions Deployment
# ======================================

# Service Account for GitHub Actions to deploy to Cloud Storage
# GitHub ActionsからCloud Storageへのデプロイを行うためのサービスアカウント
# 必要最小限の権限のみを付与して、セキュリティを確保
resource "google_service_account" "github_actions_deployer" {
  account_id   = "github-actions-dashboard"
  display_name = "GitHub Actions Dashboard Deployer"
  description  = "Service account for GitHub Actions to deploy dashboard to Cloud Storage"
}

# Grant Storage Object Admin role on the specific bucket
# バケット内のオブジェクト（ファイル）の作成・更新・削除権限のみを付与
# バケット自体の設定変更はできないため、セキュリティリスクを最小化
resource "google_storage_bucket_iam_member" "github_actions_storage_object_admin" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# Grant permission to invalidate CDN cache
# CDNキャッシュの無効化に必要な最小限の権限を定義するカスタムロール
resource "google_project_iam_custom_role" "cache_invalidator" {
  role_id     = "cacheInvalidator"
  title       = "Cache Invalidator"
  description = "Custom role for CDN cache invalidation with minimal permissions"
  permissions = [
    "compute.urlMaps.invalidateCache",
    "compute.urlMaps.get"
  ]
}

# カスタムロールをサービスアカウントに付与
resource "google_project_iam_member" "github_actions_cache_invalidator" {
  project = var.project_id
  role    = google_project_iam_custom_role.cache_invalidator.name
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}


# Workload Identity User role binding
# GitHub ActionsがサービスアカウントとしてGCPリソースにアクセスできるよう権限を付与
# 特定のリポジトリからのリクエストのみがサービスアカウントを使用できるよう制限
resource "google_service_account_iam_member" "github_actions_workload_identity_user" {
  service_account_id = google_service_account.github_actions_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${data.terraform_remote_state.shared.outputs.workload_identity_pool_name}/attribute.repository/${var.github_repository}"
}

# Create Service Account Key (一時的に残す)
# GitHub Actionsで使用するサービスアカウントキーを作成
# このキーはGitHub Secretsに登録して使用する
# NOTE: サービスアカウントキーの使用は非推奨です
# セキュリティ向上のため、Workload Identity Federationの使用を強く推奨をするが「組織」の設定が必要なため、学習用の目的でサービスアカウントを利用する
resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions_deployer.name
  key_algorithm      = "KEY_ALG_RSA_2048"
}

# HTTPS Target Proxy
# HTTPS（暗号化）接続を処理するためのプロキシを作成
# SSL/TLS証明書を使用してセキュアな通信を実現
# Certificate Managerで管理された証明書を使用してHTTPS接続を終端する
resource "google_compute_target_https_proxy" "website_https_proxy" {
  name    = "dashboard-https-proxy"
  url_map = google_compute_url_map.website_url_map.id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.website_cert_map.id}"
}

# HTTPS Forwarding Rule
# インターネットからのHTTPSリクエスト（ポート443）を受け付けるためのフォワーディングルールを作成
# 事前に取得した静的IPアドレスを使用して、一貫性のあるアクセスポイントを提供
# HTTPSプロキシと連携してセキュアな通信を実現し、本番運用に適した設定
resource "google_compute_global_forwarding_rule" "website_https_forwarding_rule" {
  name        = "dashboard-https-rule"
  target      = google_compute_target_https_proxy.website_https_proxy.id
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.website_ip.address
}
