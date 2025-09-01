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

  project_id     = var.project_id
  region         = var.region
  labels         = local.common_labels
  dev_team_group = var.dev_team_group

  # Prod環境固有の設定（学習用コスト削減設定）
  # Production recommended: min_instances=3, max_instances=10, machine_type="e2-standard-4", min_throughput=300, max_throughput=1000
  vpc_connector_min_instances  = 2             # 学習用: dev環境に合わせてコスト削減（本番推奨: 3）
  vpc_connector_max_instances  = 3             # 学習用: dev環境に合わせてコスト削減（本番推奨: 10）
  vpc_connector_machine_type   = "e2-micro"    # 学習用: dev環境に合わせてコスト削減（本番推奨: "e2-standard-4"）
  vpc_connector_min_throughput = 200           # 学習用: e2-microに適したスループット（本番推奨: 300）
  vpc_connector_max_throughput = 300           # 学習用: e2-microに適したスループット（本番推奨: 1000）
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

  # Prod環境のインフラストラクチャ設定  
  ssl_certificate_domain            = "api.my-learn-iac-sample.site" # 本番ドメイン
  private_service_connection_count  = 1                              # Cloud SQL用のPrivate Service Connection
  private_service_connection_prefix = 20                             # /20のIPアドレス範囲を確保

  # Prod環境のデータベース設定（学習用コスト削減構成）
  # Production recommended: deletion_protection=true, tier="db-custom-1-3840", backup_enabled=true, backup_retained_count=3
  database_deletion_protection            = false         # 学習用: dev環境に合わせて削除保護無効（本番推奨: true）
  database_tier                           = "db-g1-small" # 学習用: 共有コア最小インスタンス（本番推奨: "db-custom-1-3840"）
  database_availability_type              = "ZONAL"       # 単一ゾーンでコスト削減
  database_disk_size                      = 10            # 学習用: dev環境に合わせて10GB（本番推奨: 20GB）
  database_backup_retained_count          = 0             # 学習用: バックアップ無効でストレージコストゼロ（本番推奨: 3）
  database_backup_enabled                 = false         # 学習用: バックアップ無効化（本番推奨: true）
  database_transaction_log_retention_days = 1             # 学習用: 最小値（本番推奨: 3）

  # Prod環境のCloud Run設定（学習用コスト削減構成）
  # Production recommended: min_instances=1, max_instances=10, cpu_limit="2", memory_limit="1Gi"
  cloudrun_min_instances                    = 0                                                                         # 学習用: コスト削減（本番推奨: 1）
  cloudrun_max_instances                    = 3                                                                         # 学習用: dev環境に合わせてコスト削減（本番推奨: 10）
  cloudrun_image                            = "asia-northeast1-docker.pkg.dev/${var.project_id}/api-service/api:latest" # 初期ダミーイメージ
  cloudrun_cpu_limit                        = "1"                                                                       # 学習用: dev環境に合わせてコスト削減（本番推奨: "2"）
  cloudrun_memory_limit                     = "512Mi"                                                                   # 学習用: dev環境に合わせてコスト削減（本番推奨: "1Gi"）
  cloudrun_port                             = 8080                                                                      # アプリポート
  cloudrun_environment                      = "production"                                                              # 環境名
  cloudrun_health_check_path                = "/health"                                                                 # ヘルスチェックパス
  cloudrun_startup_probe_initial_delay      = 5                                                                         # 起動プローブ初期遅延（秒）- 本番は短め
  cloudrun_startup_probe_timeout            = 9                                                                         # 起動プローブタイムアウト（秒）- periodより小さく設定
  cloudrun_startup_probe_period             = 10                                                                        # 起動プローブ間隔（秒）- timeoutより大きく設定
  cloudrun_startup_probe_failure_threshold  = 5                                                                         # 起動プローブ失敗しきい値 - 本番は多め
  cloudrun_liveness_probe_initial_delay     = 60                                                                        # 生存プローブ初期遅延（秒）
  cloudrun_liveness_probe_timeout           = 10                                                                        # 生存プローブタイムアウト（秒）
  cloudrun_liveness_probe_period            = 60                                                                        # 生存プローブ間隔（秒）
  cloudrun_liveness_probe_failure_threshold = 5

  # Dashboard設定
  dashboard_domain_name           = "dashboard.my-learn-iac-sample.site" # Dashboard用ドメイン
  dashboard_enable_cdn            = true                                 # CDN有効化
  dashboard_cdn_cache_mode        = "CACHE_ALL_STATIC"                   # 静的ファイルをキャッシュ
  dashboard_cdn_default_ttl       = 7200                                 # デフォルトTTL（2時間・prod用）
  dashboard_cdn_client_ttl        = 7200                                 # クライアントTTL（2時間・prod用）
  dashboard_cdn_max_ttl           = 172800                               # 最大TTL（48時間・prod用）
  dashboard_cdn_serve_while_stale = 172800                               # ステイル配信時間（48時間・prod用）
  dashboard_force_destroy_bucket  = false                                # 本番環境ではバケット削除保護
}
