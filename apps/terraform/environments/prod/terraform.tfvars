# ======================================
# Prod Environment Terraform Variables
# ======================================

# プロジェクト基本設定
project_id = "your-gcp-project-id"
region     = "asia-northeast1"
zone       = "asia-northeast1-a"

# リソースラベル
labels = {
  team = "platform"
}

# IAM & GitHub Actions設定
dev_team_group    = "dev-team@your-domain.com"
github_repository = "gonta1026/turborepo-project"

# Dashboard設定
bucket_name = "" # 空の場合は自動生成
domain_name = "prod.dashboard.your-domain.com"

# API設定
api_domain_name = "prod.api.your-domain.com"

# Database設定
database_name = "api_db"
database_user = "api_user"

# CORS設定
dashboard_client_url = "https://prod.dashboard.your-domain.com"
