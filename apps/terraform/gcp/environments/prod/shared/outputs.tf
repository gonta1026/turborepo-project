# Outputs for Production Shared Environment
# dashboardやapi ディレクトリから参照されるリソースIDや設定値を出力

# Project Information
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

# ======================================
# Network Infrastructure Outputs
# ======================================

# VPC Network Outputs
output "vpc_network_id" {
  description = "Main VPC network ID"
  value       = google_compute_network.main_vpc.id
}

output "vpc_network_name" {
  description = "Main VPC network name"
  value       = google_compute_network.main_vpc.name
}

# Subnet Outputs
output "public_subnet_id" {
  description = "Public subnet ID"
  value       = google_compute_subnetwork.public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = google_compute_subnetwork.private_subnet.id
}

# ======================================
# Static IP Addresses
# ======================================

# API Static IP
output "api_static_ip_address" {
  description = "API Load Balancer static IP address (⚠️ Use this for DNS record)"
  value       = google_compute_global_address.api_ip.address
}

output "api_static_ip_id" {
  description = "API Load Balancer static IP resource ID"
  value       = google_compute_global_address.api_ip.id
}

# ======================================
# Serverless VPC Access Connector
# ======================================

output "vpc_connector_id" {
  description = "VPC Access Connector ID for Cloud Run services"
  value       = google_vpc_access_connector.main_connector.id
}

output "vpc_connector_name" {
  description = "VPC Access Connector name"
  value       = google_vpc_access_connector.main_connector.name
}

# Certificate Map
output "shared_certificate_map" {
  description = "Shared Certificate Map name"
  value = {
    name = google_certificate_manager_certificate_map.shared_cert_map.name
    id   = google_certificate_manager_certificate_map.shared_cert_map.id
  }
}