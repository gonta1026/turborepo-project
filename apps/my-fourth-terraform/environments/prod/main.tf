# ======================================
# Prod Environment - Module-based Configuration
# ======================================
# modules/を使用したモジュール構成

# ======================================
# Local Values
# ======================================

locals {

  common_labels = {
    team       = "platform"
    managed_by = "terraform"
  }
}

# ======================================
# Shared Module
# ======================================

module "shared" {
  source = "../../modules/shared"

  project_id        = var.project_id
  region            = var.region
  labels            = local.common_labels
  dev_team_group    = var.dev_team_group
  github_repository = var.github_repository

  # Prod環境固有の設定
  vpc_connector_min_instances     = 3
  vpc_connector_max_instances     = 10
  vpc_connector_machine_type      = "e2-standard-4"
  vpc_connector_min_throughput    = 300        # 現在の設定を維持
  vpc_connector_max_throughput    = 1000       # 現在の設定を維持
  subnet_flow_sampling            = 0.5        # 本番環境は詳細ログ
  nat_log_filter                  = "ERRORS_ONLY" # エラーのみログ出力
  bucket_lifecycle_age_days       = 90        # 長期保存
}
