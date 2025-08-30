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
  vpc_connector_min_instances  = 2
  vpc_connector_max_instances  = 3
  vpc_connector_machine_type   = "e2-micro"
  vpc_connector_min_throughput = 200   # e2-microに適したスループット
  vpc_connector_max_throughput = 300   # e2-microに適したスループット
  subnet_flow_sampling         = 0.1   # 開発環境はログ量を削減
  nat_log_filter               = "ALL" # 開発時はすべてログ出力
  bucket_lifecycle_age_days    = 7     # 短期保存

  # Dev環境のファイアウォール設定（開発用に緩和）
  firewall_http_source_ranges = ["0.0.0.0/0"]                 # 全世界からのアクセス許可
  firewall_health_check_ports = ["80", "8080", "443", "3000"] # 開発用ポート追加
  firewall_internal_tcp_ports = ["0-65535"]                   # 全TCPポート許可
  firewall_internal_udp_ports = ["0-65535"]                   # 全UDPポート許可
  firewall_ssh_count          = 1                             # 開発環境ではSSH有効
  firewall_ssh_source_ranges  = ["0.0.0.0/0"]                 # 開発用に全世界許可（要注意）

  # Dev環境のインフラストラクチャ設定
  ssl_certificate_domain            = "dev.api.my-learn-iac-sample.site" # 開発用ドメイン
  private_service_connection_count  = 1                                  # Cloud SQL用のPrivate Service Connection
  private_service_connection_prefix = 20

  # Dev環境のデータベース設定（最小コスト構成）
  database_deletion_protection            = false         # 開発環境では削除保護を無効（再作成容易）
  database_tier                           = "db-g1-small" # 共有コア最小インスタンス（最安値）
  database_availability_type              = "ZONAL"       # 単一ゾーンでコスト削減
  database_disk_size                      = 10            # 10GB最小サイズ（開発用は十分）
  database_backup_retained_count          = 0             # バックアップ無効でストレージコストゼロ
  database_backup_enabled                 = false         # バックアップを無効化
  database_transaction_log_retention_days = 1             # 最小値（バックアップ無効時でも必要）

  # Dev環境のCloud Run設定（開発効率重視）
  cloudrun_min_instances                    = 0                                                                         # 最小インスタンス数（コスト削減）
  cloudrun_max_instances                    = 3                                                                         # 最大インスタンス数（開発用適度な制限）
  cloudrun_image                            = "asia-northeast1-docker.pkg.dev/${var.project_id}/api-service/api:latest" # 初期ダミーイメージ
  cloudrun_cpu_limit                        = "1"                                                                       # CPU制限（1vCPU）
  cloudrun_memory_limit                     = "512Mi"                                                                   # メモリ制限（512MB）
  cloudrun_port                             = 8080                                                                      # アプリポート
  cloudrun_environment                      = "development"                                                             # 環境名
  cloudrun_health_check_path                = "/health"                                                                 # ヘルスチェックパス
  cloudrun_startup_probe_initial_delay      = 10                                                                        # 起動プローブ初期遅延（秒）
  cloudrun_startup_probe_timeout            = 5                                                                         # 起動プローブタイムアウト（秒）
  cloudrun_startup_probe_period             = 10                                                                        # 起動プローブ間隔（秒）
  cloudrun_startup_probe_failure_threshold  = 3                                                                         # 起動プローブ失敗しきい値
  cloudrun_liveness_probe_initial_delay     = 30                                                                        # 生存プローブ初期遅延（秒）
  cloudrun_liveness_probe_timeout           = 5                                                                         # 生存プローブタイムアウト（秒）
  cloudrun_liveness_probe_period            = 30                                                                        # 生存プローブ間隔（秒）
  cloudrun_liveness_probe_failure_threshold = 3                                                                         # 生存プローブ失敗しきい値
}

