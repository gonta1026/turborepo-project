# ======================================
# TERRAFORM VALUES - Prod Environment
# 全サービス共通の設定値ファイル
# ======================================

# ======================================
# プロジェクト基本設定
# ======================================

project_id = "my-fourth-prod"

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

dev_team_group = "prod-developer@rakushite-inc.jp" # Google Workspace group: prod-rakushite-developers
