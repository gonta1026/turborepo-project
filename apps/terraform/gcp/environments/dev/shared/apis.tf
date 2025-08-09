# ======================================
# Enable Required APIs
# ======================================

# Enable Certificate Manager API
# Google Certificate Managerを使用してSSL証明書を自動管理するためのAPIを有効化
# これにより、ドメインの証明書を自動取得・更新できるようになる
resource "google_project_service" "certificate_manager_api" {
  service = "certificatemanager.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Compute Engine API (if not already enabled)
# ロードバランサー、グローバルIPアドレス、URLマップなどの作成に必要なCompute Engine APIを有効化
# 静的IPアドレスの取得やHTTPS/HTTPプロキシの作成に使用される
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Secret Manager API
# APIサービスの機密情報（データベースパスワード、APIキー等）を安全に管理するためのAPIを有効化
# 暗号化された状態でシークレットを保存し、アプリケーションから安全にアクセスできる
resource "google_project_service" "secret_manager_api" {
  service = "secretmanager.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable SQL Admin API
# Cloud SQLインスタンス、データベース、ユーザーの管理に必要なAPIを有効化
# プライベートCloud SQLインスタンスの作成・設定・管理に使用される
resource "google_project_service" "sql_admin_api" {
  service = "sqladmin.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Service Networking API
# VPCとGoogle管理サービス（Cloud SQL等）間のプライベート接続に必要なAPIを有効化
# プライベートサービス接続やVPCピアリングの設定に使用される
resource "google_project_service" "service_networking_api" {
  service = "servicenetworking.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable IAP API
# プライベートインスタンスへのSSH接続に必要なIdentity-Aware Proxy APIを有効化
# パブリックIPなしのCompute EngineへのSSHアクセスに使用される
resource "google_project_service" "iap_api" {
  service = "iap.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Serverless VPC Access API
# Cloud RunサービスがVPCネットワーク内のリソースにアクセスするためのAPIを有効化
# VPCアクセスコネクターの作成・管理に使用される
resource "google_project_service" "vpcaccess_api" {
  service = "vpcaccess.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Cloud Run Admin API
# Cloud Runサービスの作成・管理・設定に必要なAPIを有効化
# Cloud Runサービスのデプロイ、設定変更、管理に使用される
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}
