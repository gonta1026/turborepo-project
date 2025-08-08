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
