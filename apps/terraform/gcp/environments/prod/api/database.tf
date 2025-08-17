# ======================================
# Cloud SQL PostgreSQL Instance - Private Configuration
# ======================================
# セキュアなプライベートCloud SQLインスタンスの構築
# パブリックIPを完全に無効化し、VPC内部からのみアクセス可能

# Generate random password for database user
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Cloud SQL Instance (Private)
resource "google_sql_database_instance" "api_db_instance" {
  name             = "api-db-instance"
  database_version = "POSTGRES_17"
  region           = var.region

  # インスタンス削除保護（本番運用では有効化）
  deletion_protection = true

  settings {
    # マシンタイプ（学習用の小さなインスタンス、実際の本番では db-n1-standard-2 以上推奨）
    tier = "db-g1-small"

    # 可用性設定（学習用はZONAL、実際の本番では REGIONAL 推奨）
    availability_type = "ZONAL"

    # ディスク設定（学習用の最小サイズ、実際の本番では初期50GB以上推奨）
    disk_type             = "PD_SSD"
    disk_size             = 10 # GB
    disk_autoresize       = true
    disk_autoresize_limit = 100 # GB（実際の本番では500GB以上推奨）

    # バックアップ設定
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00" # JST 12:00 (UTC+9)
      location                       = var.region
      point_in_time_recovery_enabled = true

      backup_retention_settings {
        retained_backups = 7 # 7日間保持
        retention_unit   = "COUNT"
      }
    }

    # メンテナンス設定
    maintenance_window {
      day          = 1  # 日曜日
      hour         = 15 # JST 24:00 (UTC+9)
      update_track = "stable"
    }

    # IP設定（プライベートのみ）
    ip_configuration {
      # パブリックIPを完全無効化
      ipv4_enabled    = false
      private_network = data.terraform_remote_state.shared.outputs.vpc_network_id

      # プライベートサービス接続を利用
      enable_private_path_for_google_cloud_services = true
    }

    # パフォーマンスインサイト有効化
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
    }

    # IAM認証有効化（パスワード認証と併用）
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    # ユーザーラベル
    user_labels = var.labels
  }

  # sharedのプライベートサービス接続とAPI有効化に依存
  depends_on = [data.terraform_remote_state.shared]
}

# ======================================
# Database and User Configuration
# ======================================

# Database
resource "google_sql_database" "api_database" {
  name     = var.database_name
  instance = google_sql_database_instance.api_db_instance.name

  # 文字セット設定（UTF-8）
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

# Database User (Password-based)
resource "google_sql_user" "api_user" {
  name     = var.database_user
  instance = google_sql_database_instance.api_db_instance.name
  password = random_password.db_password.result
}
