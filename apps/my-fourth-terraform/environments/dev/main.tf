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

  # Dev環境固有の設定
  vpc_connector_min_instances     = 2
  vpc_connector_max_instances     = 3
  vpc_connector_machine_type      = "e2-micro"
  vpc_connector_min_throughput    = 200        # e2-microに適したスループット
  vpc_connector_max_throughput    = 300        # e2-microに適したスループット
  subnet_flow_sampling            = 0.1        # 開発環境はログ量を削減
  nat_log_filter                  = "ALL"      # 開発時はすべてログ出力
  bucket_lifecycle_age_days       = 7          # 短期保存
}

