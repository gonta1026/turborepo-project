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

  # Prod環境のインフラストラクチャ設定  
  ssl_certificate_domain            = "api.my-learn-iac-sample.site" # 本番ドメイン
  private_service_connection_count  = 1                              # Cloud SQL用のPrivate Service Connection
  private_service_connection_prefix = 20                             # /20のIPアドレス範囲を確保

  # Prod環境のデータベース設定（最小コスト構成）
  database_deletion_protection            = true               # 本番環境では削除保護を有効（誤削除防止）
  database_tier                           = "db-custom-1-3840" # PostgreSQL用最小構成（1vCPU, 3.75GB）
  database_availability_type              = "ZONAL"            # 単一ゾーンでコスト削減（本番でも最小コスト重視）
  database_disk_size                      = 20                 # 20GB（必要最小限サイズ）
  database_backup_retained_count          = 3                  # バックアップ保持数（最小限の3日間）
  database_backup_enabled                 = true               # バックアップを有効化
  database_transaction_log_retention_days = 3                  # バックアップ保持数と同じに設定

  # Prod環境のCloud Run設定（本番信頼性重視）
  cloudrun_min_instances                    = 0                                                                         # 学習のために0にしている。                                                                    # 学習用なので 0にしているが、本番の時は1にしておくこと                                                                         # 最小インスタンス数（常時起動でレスポンス向上）
  cloudrun_max_instances                    = 10                                                                        # 最大インスタンス数（トラフィック増加に対応）
  cloudrun_image                            = "asia-northeast1-docker.pkg.dev/${var.project_id}/api-service/api:latest" # 初期ダミーイメージ
  cloudrun_cpu_limit                        = "2"                                                                       # CPU制限（2vCPU）
  cloudrun_memory_limit                     = "1Gi"                                                                     # メモリ制限（1GB）
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
