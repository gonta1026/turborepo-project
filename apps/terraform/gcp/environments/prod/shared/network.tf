# ======================================
# VPC Network Infrastructure
# ======================================
# API・将来のサービス用の共通ネットワーク基盤
# Cloud Run・Cloud SQL・その他のサービスが安全に通信できるVPC環境を提供

# Main VPC Network
# dashboard・api・将来のサービス全体で共有するメインVPCネットワーク
# プライベートなクラウド環境を提供し、外部からの直接アクセスを制限
resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  description             = "Main VPC for all services (dashboard, api, future services)"
  auto_create_subnetworks = false # サブネットは明示的に作成
  routing_mode            = "REGIONAL"

  # ネットワーク削除保護（本番運用時）
  delete_default_routes_on_create = false
}

# ======================================
# Subnet Configuration
# ======================================
# RFC1918準拠のプライベートIPアドレス体系
# /24サブネットで250個のIPアドレスを確保（将来の拡張を考慮）

# Public Subnet (Load Balancer用)
# Cloud Load Balancerやプロキシリソース用
# 外部からのHTTPS接続を受け付けるためのサブネット
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.1.1.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
  description   = "Public subnet for load balancers and proxy resources"

  # Private Google Accessを有効化
  # Cloud Load BalancerがGoogle APIにアクセスできるようにする
  private_ip_google_access = true
}

# Private Subnet (Cloud SQL・Cloud Run用)
# データベースやアプリケーションサーバーを配置するプライベートサブネット
# インターネットから直接アクセスできないセキュアな環境
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.1.2.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
  description   = "Private subnet for Cloud SQL and Cloud Run services"

  # Private Google Accessを有効化
  # プライベートサブネット内のリソースがGoogle APIにアクセスできるようにする
  private_ip_google_access = true
}

# ======================================
# Private Service Connection for Cloud SQL
# ======================================
# Cloud SQLプライベートインスタンス用の専用IP範囲
# Google管理のサービス（Cloud SQL）がVPC内でプライベートIPを使用するための設定

# Reserve IP range for private services
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main_vpc.id
  description   = "IP range reserved for private service connection (Cloud SQL)"
}

# Private connection to Google services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [google_compute_global_address.private_ip_alloc]
}

# ======================================
# Static IP Addresses
# ======================================
# API用のグローバル静的IPアドレス
# ドメインのDNS設定で使用するためのIPアドレスを事前に取得

# Global Static IP Address for API Load Balancer
resource "google_compute_global_address" "api_ip" {
  name         = "api-ip"
  description  = "Static IP for API HTTPS load balancer"
  address_type = "EXTERNAL"
  # IPアドレスは自動的に割り当てられます
}

# ======================================
# Serverless VPC Access Connector
# ======================================
# Cloud RunサービスがVPCネットワーク内のリソース（Cloud SQL等）にアクセスするためのコネクター
# Cloud Runはサーバーレスのため、デフォルトではVPCに接続されていない

# VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "main_connector" {
  name          = "main-connector"
  ip_cidr_range = "10.1.4.0/28"  # /28で16個のIPアドレスを使用
  network       = google_compute_network.main_vpc.name
  region        = var.region
  
  # コネクターの最小・最大インスタンス数
  min_instances = 2
  max_instances = 10
  
  # マシンタイプ（小規模構成）
  machine_type = "e2-micro"
  
  # スループット設定（現在のリソースに合わせる）
  max_throughput = 1000

  depends_on = [google_compute_network.main_vpc]
}
