# ======================================
# Shared Resources Module
# ======================================
# VPC、IAM、基盤リソースを管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project    = var.project_id
    managed_by = "terraform"
  })

  network_name = "api-vpc"

  public_subnet_cidr     = "10.0.1.0/24"
  private_subnet_cidr    = "10.0.2.0/24"
  management_subnet_cidr = "10.0.3.0/24"
  vpc_connector_cidr     = "10.8.0.0/28"
}

# ======================================
# GCPプロジェクト参照
# ======================================
# Note: プロジェクトは手動で作成済み

# ======================================
# API有効化
# ======================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # VM、ネットワーク、ロードバランサー
    "iam.googleapis.com",                  # 権限管理
    "iamcredentials.googleapis.com",       # サービスアカウント認証
    "storage.googleapis.com",              # GCSバケット管理
    "storage-api.googleapis.com",          # GCSデータアクセス
    "cloudresourcemanager.googleapis.com", # プロジェクト、フォルダ管理
    "serviceusage.googleapis.com",         # API有効化・無効化管理
    "cloudapis.googleapis.com",            # Google Cloud API基盤サービス
    "monitoring.googleapis.com",           # Cloud Monitoring（メトリクス）
    "logging.googleapis.com",              # Cloud Logging（ログ管理）
    "cloudidentity.googleapis.com",        # Googleグループ、ユーザー管理
    "artifactregistry.googleapis.com",     # Artifact Registry
    "run.googleapis.com",                  # Cloud Run
    "cloudbuild.googleapis.com",           # Cloud Build
    "servicenetworking.googleapis.com",    # Provides automatic management of network configurations
    "sql-component.googleapis.com",        # Provides automatic management of network configurations
    "sqladmin.googleapis.com",             # Cloud SQL
    "cloudkms.googleapis.com",             # Cloud KMS
    "secretmanager.googleapis.com",        # Secret Manager
    "certificatemanager.googleapis.com",   # Certificate Manager
    "vpcaccess.googleapis.com",            # VPC Access Connector
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

}


# ======================================
# サービスアカウント
# ======================================
# GitHub ActionsからGCPリソースにアクセスするためのサービスアカウント

resource "google_service_account" "github_actions_deployer" {
  project      = var.project_id                                  # 所属するプロジェクトID
  account_id   = "github-actions-deployer"                       # サービスアカウントID（プロジェクト内でユニーク）
  display_name = "GitHub Actions Deployer"                       # 人間が読みやすい表示名
  description  = "Service account for GitHub Actions deployment" # サービスアカウントの用途説明

  depends_on = [google_project_service.required_apis] # IAM APIが有効化された後に作成
}

# ======================================
# Workload Identity Federation
# ======================================
# GitHub ActionsからGCPに安全にアクセスするための認証メカニズム
# サービスアカウントキーを使わず、OIDCトークンベースで認証

# Workload Identity Pool作成
resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = var.project_id                              # 所属するプロジェクトID
  workload_identity_pool_id = "github-actions-pool"                       # プールID（プロジェクト内でユニーク）
  display_name              = "GitHub Actions Pool"                       # 人間が読みやすい表示名
  description               = "Workload Identity Pool for GitHub Actions" # プールの用途説明

  depends_on = [google_project_service.required_apis] # IAM APIが有効化された後に作成
}

# Workload Identity Pool Provider作成
# GitHub ActionsのOIDCトークンを受け入れるプロバイダー設定
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = var.project_id                                                             # 所属するプロジェクトID
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id # 作成したプールを参照
  workload_identity_pool_provider_id = "github-actions-provider"                                                  # プロバイダーID（プール内でユニーク）
  display_name                       = "GitHub Actions Provider"                                                  # 人間が読みやすい表示名
  description                        = "OIDC identity pool provider for GitHub Actions"                           # プロバイダーの用途説明

  # GitHubのJWTトークンからGoogleの属性へのマッピング設定
  attribute_mapping = {
    "google.subject"       = "assertion.sub"        # JWT subjectをGoogle subjectにマッピング
    "attribute.actor"      = "assertion.actor"      # 実行者情報の保存
    "attribute.repository" = "assertion.repository" # リポジトリ名の保存（アクセス制御に使用）
    "attribute.ref"        = "assertion.ref"        # ブランチ/タグ情報の保存
  }

  # OIDC設定：GitHubのトークン発行者を指定
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com" # GitHub ActionsのOIDC発行者URL
  }

  # セキュリティ制約：指定したGitHubリポジトリからのアクセスのみ許可
  attribute_condition = "assertion.repository=='${var.github_repository}'"
}

# サービスアカウントにWorkload Identity権限を付与
# 指定したGitHubリポジトリからサービスアカウントの偽装を許可
resource "google_service_account_iam_member" "github_actions_workload_identity" {
  service_account_id = google_service_account.github_actions_deployer.name # 対象サービスアカウント
  role               = "roles/iam.workloadIdentityUser"                    # Workload Identity使用権限
  # 特定のGitHubリポジトリからのアクセスのみを許可するメンバー設定
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.github_repository}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github_actions # プロバイダー作成後に実行
  ]
}

# ======================================
# Terraform State用GCSバケット
# ======================================
# Terraformのステートファイルを安全に保存するためのGCSバケット
# バージョニング、ライフサイクル管理、アクセス制御を設定

resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state" # バケット名：プロジェクトID-terraform-state
  location      = var.region                          # バケットのリージョン指定
  storage_class = "STANDARD"                          # 標準ストレージクラス（アクセス頻度が高い用途）
  project       = var.project_id                      # 所属するプロジェクトID

  uniform_bucket_level_access = true # バケットレベルの統一アクセス制御を有効化（推奨設定）

  versioning {
    enabled = true # Terraformステートファイルのバージョニングを有効化（誤削除防止）
  }

  # 古いバージョンの自動削除
  lifecycle_rule {
    action {
      type = "Delete" # 削除アクション
    }
    condition {
      num_newer_versions = 5          # 5つ以上の新しいバージョンが存在する場合
      with_state         = "ARCHIVED" # アーカイブ状態のオブジェクトが対象
    }
  }

  # 非現行バージョンの自動アーカイブ
  lifecycle_rule {
    action {
      type          = "SetStorageClass" # ストレージクラス変更アクション
      storage_class = "NEARLINE"        # より安価なNEARLINEクラスに変更
    }
    condition {
      age        = var.bucket_lifecycle_age_days # 指定日数経過したオブジェクト
      with_state = "LIVE"                        # ライブ状態のオブジェクトが対象
    }
  }

  labels = merge(local.common_labels, {
    purpose = "terraform-state" # このバケットの用途を示すラベル
  })

  depends_on = [google_project_service.required_apis] # 必要なAPIが有効化された後に作成
}

# ======================================
# VPCネットワーク
# ======================================
# プロジェクト全体で使用するメインVPCネットワーク
# カスタムサブネット設計でネットワークを細かく制御

resource "google_compute_network" "main_vpc" {
  name                    = local.network_name # VPCネットワーク名（"main-vpc"）
  auto_create_subnetworks = false              # サブネットの自動作成を無効化（手動でサブネットを作成するため）
  mtu                     = 1460               # Maximum Transmission Unit（GCPのデフォルト値）
  project                 = var.project_id     # 所属するプロジェクトID

  depends_on = [google_project_service.required_apis] # Compute APIが有効化された後に作成
}

# ======================================
# サブネット
# ======================================
# パブリック・プライベートサブネット構成でセキュリティを確保
# フローログ設定でネットワーク監視を実現

# パブリックサブネット：Load BalancerやNAT Gatewayを配置
resource "google_compute_subnetwork" "public_subnet" {
  name          = "api-public"                       # パブリックサブネット名
  ip_cidr_range = local.public_subnet_cidr           # IPアドレス範囲（10.0.1.0/24）
  region        = var.region                         # サブネットのリージョン
  network       = google_compute_network.main_vpc.id # 所属するVPCネットワーク
  project       = var.project_id                     # 所属するプロジェクトID

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"        # ログ集約間隔（10分間隔）
    flow_sampling        = var.subnet_flow_sampling # フローサンプリング率
    metadata             = "INCLUDE_ALL_METADATA"   # 全メタデータを含める
  }
}

# プライベートサブネット：Cloud SQLやその他のバックエンドサービスを配置
resource "google_compute_subnetwork" "private_subnet" {
  name          = "api-private"                      # プライベートサブネット名
  ip_cidr_range = local.private_subnet_cidr          # IPアドレス範囲（10.0.2.0/24）
  region        = var.region                         # サブネットのリージョン
  network       = google_compute_network.main_vpc.id # 所属するVPCネットワーク
  project       = var.project_id                     # 所属するプロジェクトID

  private_ip_google_access = true # プライベートIPからGoogleサービスへのアクセスを許可

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"        # ログ集約間隔（10分間隔）
    flow_sampling        = var.subnet_flow_sampling # フローサンプリング率
    metadata             = "INCLUDE_ALL_METADATA"   # 全メタデータを含める
  }
}

# ======================================
# Cloud Router & NAT
# ======================================
# プライベートサブネットからインターネットへのアウトバウンド接続を提供
# Cloud SQLやVPCコネクタからの外部API通信を可能にする

# Cloud Router：NAT Gatewayの基盤となるルーター
resource "google_compute_router" "main_router" {
  name    = "api-router"                      # Cloud Router名
  region  = var.region                         # ルーターのリージョン
  network = google_compute_network.main_vpc.id # 所属するVPCネットワーク
  project = var.project_id                     # 所属するプロジェクトID

  bgp {
    asn = 64514 # BGP Autonomous System Number（プライベートASN範囲）
  }

  depends_on = [google_project_service.required_apis] # Compute APIが有効化された後に作成
}

# Cloud NAT：プライベートIPからの外部アクセスを実現
# NATとは Network Address Translationの略。 「ネットワークアドレス変換」ともいう。
resource "google_compute_router_nat" "main_nat" {
  name                               = "api-nat"                             # Cloud NAT名
  router                             = google_compute_router.main_router.name # 使用するCloud Router
  region                             = var.region                             # NATのリージョン
  project                            = var.project_id                         # 所属するプロジェクトID
  nat_ip_allocate_option             = "AUTO_ONLY"                            # 外部IPアドレスの自動割り当て
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"        # 全サブネットの全IP範囲をNAT対象とする

  log_config {
    enable = true               # NATログを有効化
    filter = var.nat_log_filter # ログフィルター設定
  }
}

# ======================================
# VPC Access Connector
# ======================================
# Cloud RunからVPCネットワーク内のリソース（Cloud SQL等）への接続を提供
# サーバーレスサービスとVPCの橋渡し役として機能

resource "google_vpc_access_connector" "main_connector" {
  name          = "api-connector"                     # VPC Access Connector名
  project       = var.project_id                       # 所属するプロジェクトID
  region        = var.region                           # Connectorのリージョン
  ip_cidr_range = local.vpc_connector_cidr             # 専用サブネット範囲（10.8.0.0/28）
  network       = google_compute_network.main_vpc.name # 接続先VPCネットワーク

  # スケーリング設定：トラフィック量に応じてインスタンス数を自動調整
  min_instances = var.vpc_connector_min_instances # 最小インスタンス数（コスト効率を考慮）
  max_instances = var.vpc_connector_max_instances # 最大インスタンス数（負荷対応力を考慮）

  # インスタンス設定：パフォーマンスとコストのバランスを調整
  machine_type = var.vpc_connector_machine_type # マシンタイプ（f1-micro, e2-micro, e2-standard-4から選択）

  # スループット設定：予期しない変更を防ぐため明示的に指定
  min_throughput = var.vpc_connector_min_throughput # 最小スループット (Mbps)
  max_throughput = var.vpc_connector_max_throughput # 最大スループット (Mbps)

  depends_on = [google_project_service.required_apis] # VPC Access APIが有効化された後に作成
}

# ======================================
# ファイアウォールルール
# ======================================
# VPCネットワークのトラフィック制御とセキュリティ強化
# 環境別（dev/prod）で異なるセキュリティポリシーを適用

# HTTP/HTTPS トラフィック許可ルール
resource "google_compute_firewall" "allow_http_https" {
  name    = "${local.network_name}-allow-http-https" # ファイアウォールルール名
  network = google_compute_network.main_vpc.name     # 対象VPCネットワーク
  project = var.project_id                           # 所属するプロジェクトID

  # 許可する通信
  allow {
    protocol = "tcp"         # TCP通信
    ports    = ["80", "443"] # HTTP(80), HTTPS(443)ポート
  }

  # 通信の方向と対象
  direction     = "INGRESS"                       # 受信トラフィック
  source_ranges = var.firewall_http_source_ranges # 許可するソースIP範囲（環境別設定）
  target_tags   = ["http-server", "https-server"] # 対象インスタンスのタグ

  depends_on = [google_compute_network.main_vpc] # VPC作成後に実行
}

# ヘルスチェック用ファイアウォールルール  
resource "google_compute_firewall" "allow_health_check" {
  name    = "${local.network_name}-allow-health-check" # ファイアウォールルール名
  network = google_compute_network.main_vpc.name       # 対象VPCネットワーク
  project = var.project_id                             # 所属するプロジェクトID

  # 許可する通信
  allow {
    protocol = "tcp"                           # TCP通信
    ports    = var.firewall_health_check_ports # ヘルスチェック用ポート（環境別設定）
  }

  # Google Cloud Load Balancerのヘルスチェック用IPレンジ
  direction = "INGRESS" # 受信トラフィック  
  source_ranges = [
    "130.211.0.0/22", # Google Cloud Load Balancer
    "35.191.0.0/16"   # Google Cloud Load Balancer
  ]
  target_tags = ["health-check"] # ヘルスチェック対象タグ

  depends_on = [google_compute_network.main_vpc] # VPC作成後に実行
}

# 内部通信許可ルール
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.network_name}-allow-internal" # ファイアウォールルール名
  network = google_compute_network.main_vpc.name   # 対象VPCネットワーク
  project = var.project_id                         # 所属するプロジェクトID

  # 全プロトコル許可
  allow {
    protocol = "tcp"                           # TCP通信
    ports    = var.firewall_internal_tcp_ports # 内部通信用TCPポート（環境別設定）
  }

  allow {
    protocol = "udp"                           # UDP通信
    ports    = var.firewall_internal_udp_ports # 内部通信用UDPポート（環境別設定）
  }

  allow {
    protocol = "icmp" # ICMP（ping等）
  }

  # VPC内部からの通信を許可
  direction = "INGRESS" # 受信トラフィック
  source_ranges = [
    local.public_subnet_cidr,  # パブリックサブネット（10.0.1.0/24）
    local.private_subnet_cidr, # プライベートサブネット（10.0.2.0/24）
    local.vpc_connector_cidr   # VPCコネクタ（10.8.0.0/28）
  ]

  depends_on = [google_compute_network.main_vpc] # VPC作成後に実行
}

# SSH接続許可ルール（環境別制御）
resource "google_compute_firewall" "allow_ssh" {
  count   = var.firewall_ssh_count               # 環境別でcount値を直接指定
  name    = "${local.network_name}-allow-ssh"    # ファイアウォールルール名
  network = google_compute_network.main_vpc.name # 対象VPCネットワーク
  project = var.project_id                       # 所属するプロジェクトID

  # SSH通信許可
  allow {
    protocol = "tcp"  # TCP通信
    ports    = ["22"] # SSHポート
  }

  # SSH接続の制御
  direction     = "INGRESS"                      # 受信トラフィック
  source_ranges = var.firewall_ssh_source_ranges # SSH許可IP範囲（環境別設定）
  target_tags   = ["ssh-server"]                 # SSH接続対象タグ

  depends_on = [google_compute_network.main_vpc] # VPC作成後に実行
}

# ======================================
# 静的IPアドレス（Load Balancer用）
# ======================================
# Global Load Balancerで使用する外部静的IPアドレス
# DNSレコード（api.domain.com）でドメイン名と関連付けるために必要
# Cloud Run APIは Load Balancer → Cloud Run の経路でアクセスされる

resource "google_compute_global_address" "main_static_ip" {
  name         = "api-static-ip" # Load Balancer用静的IP名
  project      = var.project_id   # 所属するプロジェクトID
  address_type = "EXTERNAL"       # 外部アクセス用IP
  ip_version   = "IPV4"           # IPv4アドレス

  depends_on = [google_project_service.required_apis] # Compute APIが有効化された後に作成
}

# ======================================
# SSL証明書（Certificate Manager）
# ======================================
# HTTPSアクセス用のSSL/TLS証明書を自動管理
# 証明書の自動更新と検証を行う

resource "google_certificate_manager_certificate" "main_ssl_cert" {
  count   = var.ssl_certificate_count # 環境別でSSL証明書作成制御
  name    = "api-ssl-cert"           # SSL証明書名
  project = var.project_id            # 所属するプロジェクトID

  managed {
    domains = var.ssl_certificate_domains # 対象ドメイン（環境別設定）
  }

  depends_on = [google_project_service.required_apis] # Certificate Manager APIが有効化された後に作成
}

# ======================================
# Artifact Registry
# ======================================
# Dockerコンテナイメージの保存と管理
# Cloud Runデプロイ用のプライベートレジストリ

resource "google_artifact_registry_repository" "main_repo" {
  location      = var.region                                # リポジトリのリージョン
  project       = var.project_id                            # 所属するプロジェクトID
  repository_id = "api-service"                             # リポジトリID
  description   = "Container registry for api applications" # リポジトリの説明
  format        = "DOCKER"                                  # Dockerフォーマット

  labels = merge(local.common_labels, {
    purpose = "container-registry" # このリポジトリの用途を示すラベル
  })

  depends_on = [google_project_service.required_apis] # Artifact Registry APIが有効化された後に作成
}

# ======================================
# Private Service Connection
# ======================================
# Cloud SQLのプライベートIPアクセスを有効にするための設定
# VPCとGoogleサービス間のプライベート接続を確立

resource "google_compute_global_address" "private_ip_alloc" {
  count         = var.private_service_connection_count     # 環境別でPrivate Service Connection制御
  name          = "${local.network_name}-private-ip-alloc" # プライベートIPアロケーション名
  project       = var.project_id                           # 所属するプロジェクトID
  purpose       = "VPC_PEERING"                            # VPCピアリング用途
  address_type  = "INTERNAL"                               # 内部アドレス
  prefix_length = var.private_service_connection_prefix    # IPアドレス範囲のプレフィックス長

  network = google_compute_network.main_vpc.id # 対象VPCネットワーク

  depends_on = [google_project_service.required_apis] # Service Networking APIが有効化された後に作成
}

resource "google_service_networking_connection" "private_connection" {
  count                   = var.private_service_connection_count                     # Private Service Connection制御
  network                 = google_compute_network.main_vpc.id                       # 対象VPCネットワーク
  service                 = "servicenetworking.googleapis.com"                       # Googleサービスとの接続
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc[0].name] # プライベートIPレンジ

  depends_on = [
    google_compute_global_address.private_ip_alloc, # プライベートIP割り当て後に作成
    google_project_service.required_apis            # Service Networking APIが有効化された後に作成
  ]
}

