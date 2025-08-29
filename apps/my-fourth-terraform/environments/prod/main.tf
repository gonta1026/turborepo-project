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
  vpc_connector_min_instances  = 3
  vpc_connector_max_instances  = 10
  vpc_connector_machine_type   = "e2-standard-4"
  vpc_connector_min_throughput = 300           # 現在の設定を維持
  vpc_connector_max_throughput = 1000          # 現在の設定を維持
  subnet_flow_sampling         = 0.5           # 本番環境は詳細ログ
  nat_log_filter               = "ERRORS_ONLY" # エラーのみログ出力
  bucket_lifecycle_age_days    = 90            # 長期保存
  # Prod環境のファイアウォール設定（セキュリティ重視）
  firewall_http_source_ranges = ["0.0.0.0/0"]                         # 本番サービスは全世界からアクセス
  firewall_health_check_ports = ["80", "443", "8080"]                 # 本番用ポートのみ
  firewall_internal_tcp_ports = ["80", "443", "5432", "3306", "6379"] # 必要最小限のポート
  firewall_internal_udp_ports = ["53", "123"]                         # DNS、NTPのみ
  firewall_ssh_count          = 0                                     # 本番環境ではSSH無効
  firewall_ssh_source_ranges  = []                                    # SSH無効のため空
}
