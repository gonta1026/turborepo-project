# GCP Project Configuration - Dev Environment共通設定
project_id = "terraform-gcp-466623"

# Region and Zone Configuration - Asia Northeast (Tokyo)
region = "asia-northeast1"
zone   = "asia-northeast1-a"

# IAM設定 - Dev環境全体用
dev_team_group = "terraform-gcp-dev-team@googlegroups.com"

# 共通ラベル設定
labels = {
  environment = "dev"
  managed_by  = "terraform"
} 
