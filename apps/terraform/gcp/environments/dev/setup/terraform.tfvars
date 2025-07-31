# GCP Project Configuration
project_id = "terraform-gcp-466623"

# Region and Zone Configuration
region = "us-central1"
zone   = "us-central1-a"

# Cloud Storage/CDN Configuration (将来的に使用)
bucket_name = "" # 空の場合は自動生成: ${project_id}-dashboard
domain_name = "" # カスタムドメインを使用する場合は設定

# ラベル設定
labels = {
  environment = "dev"
  managed_by  = "terraform"
  purpose     = "dashboard-hosting"
}

# IAM設定
dev_team_group = "terraform-gcp-dev-team@googlegroups.com"
