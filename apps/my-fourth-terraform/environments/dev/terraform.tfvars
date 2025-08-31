# ======================================
# TERRAFORM VALUES - Dev Environment
# 全サービス共通の設定値ファイル
# ======================================

# ======================================
# プロジェクト基本設定
# ======================================

project_id = "my-fourth-dev"

# Asia Northeast (Tokyo) region configuration
region         = "asia-northeast1"
zone           = "asia-northeast1-a"
dev_team_group = "dev-developer@rakushite-inc.jp" # Google Workspace group: dev-rakushite-developers

# ======================================
# 共通ラベル設定
# ======================================

labels = {
  managed_by = "terraform"
}
