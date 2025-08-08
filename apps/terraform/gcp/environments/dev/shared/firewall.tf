# ======================================
# Firewall Rules - Zero Trust Network Security
# ======================================
# デフォルト拒否原則に基づいたセキュアなファイアウォール設定
# 最小権限でのアクセス制御を実装

# ======================================
# Default Deny Rules
# ======================================

# Deny all ingress traffic (デフォルト)
# すべての外部からの接続を基本的に拒否
# 必要な通信のみを個別に許可するゼロトラスト方式
resource "google_compute_firewall" "deny_all_ingress" {
  name        = "deny-all-ingress"
  network     = google_compute_network.main_vpc.name
  description = "Default deny rule for all ingress traffic"
  direction   = "INGRESS"
  priority    = 65534 # 低優先度（他のルールが優先される）

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["default-deny"]
}

# ======================================
# Google Cloud Load Balancer Rules
# ======================================

# Allow HTTPS Load Balancer Health Checks
# Google Cloud Load Balancerからのヘルスチェックを許可
# Load Balancerが正常性を確認するために必要
resource "google_compute_firewall" "allow_lb_health_checks" {
  name        = "allow-lb-health-checks"
  network     = google_compute_network.main_vpc.name
  description = "Allow Google Cloud Load Balancer health checks"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Google Load Balancer の IP レンジ
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["http-server", "https-server", "load-balancer-backend"]
}

# ======================================
# Cloud Run Service Rules
# ======================================

# Allow inbound HTTPS to Cloud Run services
# Cloud Runサービスへの外部HTTPS接続を許可
# API エンドポイントへのアクセス用
resource "google_compute_firewall" "allow_cloud_run_https" {
  name        = "allow-cloud-run-https"
  network     = google_compute_network.main_vpc.name
  description = "Allow HTTPS access to Cloud Run services"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cloud-run-service"]
}

# Allow Cloud Run to Cloud SQL communication
# Cloud RunからCloud SQLへの内部通信を許可
# アプリケーションがデータベースにアクセスするために必要
resource "google_compute_firewall" "allow_cloud_run_to_sql" {
  name        = "allow-cloud-run-to-sql"
  network     = google_compute_network.main_vpc.name
  description = "Allow Cloud Run to access Cloud SQL"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["5432"] # PostgreSQL default port
  }

  source_tags = ["cloud-run-service"]
  target_tags = ["cloud-sql-instance"]
}

# ======================================
# Internal Communication Rules
# ======================================

# Allow internal VPC communication
# VPC内部での通信を許可（必要最小限）
# サービス間の内部通信用
resource "google_compute_firewall" "allow_internal_vpc" {
  name        = "allow-internal-vpc"
  network     = google_compute_network.main_vpc.name
  description = "Allow internal communication within VPC"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "5432"]
  }

  allow {
    protocol = "icmp"
  }

  # VPC内部のIP範囲のみ
  source_ranges = [
    "10.1.1.0/24", # public subnet
    "10.1.2.0/24", # private subnet
    "10.1.3.0/24"  # management subnet
  ]

  target_tags = ["internal-service"]
}

# ======================================
# Management and Debugging Rules
# ======================================

# Allow SSH for debugging (restricted)
# デバッグ・管理用のSSHアクセス（制限付き）
# 緊急時のアクセス用（本番では無効化推奨）
resource "google_compute_firewall" "allow_ssh_debug" {
  name        = "allow-ssh-debug"
  network     = google_compute_network.main_vpc.name
  description = "Allow SSH for debugging and management (restricted)"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # 管理者のIP範囲のみ（必要に応じて調整）
  # source_ranges = ["YOUR_OFFICE_IP/32"]
  source_ranges = ["0.0.0.0/0"] # 開発時のみ - 本番では制限すること

  target_tags = ["ssh-debug"]
}

# ======================================
# Egress Rules
# ======================================

# Allow all egress traffic
# 外部への通信を許可（インターネットアクセス・Google API呼び出し用）
# Cloud RunやCloud SQLが外部サービスにアクセスするために必要
resource "google_compute_firewall" "allow_all_egress" {
  name        = "allow-all-egress"
  network     = google_compute_network.main_vpc.name
  description = "Allow all outbound traffic"
  direction   = "EGRESS"
  priority    = 1000

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}
