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
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  # ラベル設定
  labels = {
    purpose     = "dashboard-frontend"
    environment = "production"
    managed_by  = "terraform"
  }
}
