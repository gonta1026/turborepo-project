# GCP Project Configuration
project_id = "terraform-gcp-466623"

# Region and Zone Configuration - Asia Northeast (Tokyo)
region = "asia-northeast1"
zone   = "asia-northeast1-a"

# Internal Cloud Storage/CDN Configuration
bucket_name = "terraform-gcp-466623-internal-frontend"
domain_name = "" # カスタムドメインを使用する場合は設定

# ラベル設定 - Dev Internal専用
labels = {
  environment = "dev"
  managed_by  = "terraform"
  purpose     = "internal-hosting"
  service     = "internal"
  sub_env     = "internal"
}
