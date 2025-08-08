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

# Management Subnet (運用ツール・管理用)
# Cloud SQL Proxy、管理ツール、メンテナンス用リソース配置
# 運用時のアクセスやトラブルシューティング用途
resource "google_compute_subnetwork" "management_subnet" {
  name          = "management-subnet"
  ip_cidr_range = "10.1.3.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
  description   = "Management subnet for operational tools and maintenance"

  # Private Google Accessを有効化
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
# Cloud NAT Configuration
# ======================================
# プライベートサブネット内のリソースがインターネットにアクセスするためのNAT Gateway
# Cloud RunやCloud SQLが外部サービスにアクセスする際に必要

# Cloud Router for NAT
resource "google_compute_router" "main_router" {
  name    = "main-router"
  region  = var.region
  network = google_compute_network.main_vpc.id

  description = "Router for Cloud NAT and VPN connections"

  bgp {
    asn = 64514
  }
}

# Cloud NAT Gateway
resource "google_compute_router_nat" "main_nat" {
  name                               = "main-nat"
  router                             = google_compute_router.main_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # プライベートサブネットのみNATを使用
  # パブリックサブネットは直接インターネットアクセス可能
  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.management_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  # ログ設定（デバッグ・監視用）
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [google_compute_router.main_router]
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
