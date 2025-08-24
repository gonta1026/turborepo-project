# ======================================
# TERRAFORM VALUES - Dev Environment
# 全サービス共通の設定値ファイル
# ======================================

# ======================================
# プロジェクト基本設定
# ======================================

project_id = "my-third-dev"

# Asia Northeast (Tokyo) region configuration
region = "asia-northeast1"
zone   = "asia-northeast1-a"

# ======================================
# 共通ラベル設定
# ======================================

labels = {
  managed_by = "terraform"
}

# ======================================
# IAM & GitHub Actions設定
# ======================================

dev_team_group = "dev-my-third-developers@rakushite-inc.jp"

github_repository = "gonta1026/turborepo-project"

# ======================================
# Dashboard設定
# ======================================

# bucket_name = "my-third-dev-dashboard-frontend"
# domain_name = "dev.dashboard.my-learn-iac-sample.site"

# ======================================
# API設定
# ======================================

# api_domain_name = "dev.api.my-learn-iac-sample.site"

# ======================================
# Database設定
# ======================================

# database_name = "api_db"
# database_user = "api_user"

# ======================================
# CORS設定
# ======================================

# dashboard_client_url = "https://dev.dashboard.my-learn-iac-sample.site"
