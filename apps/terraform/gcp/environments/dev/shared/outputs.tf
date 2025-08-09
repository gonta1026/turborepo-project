# Outputs for Dev Shared Environment
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

output "dev_team_group" {
  description = "Development team Google group email"
  value       = var.dev_team_group
}

# Workload Identity Federation
output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = google_iam_workload_identity_pool.github_actions_pool.id
}

output "workload_identity_pool_name" {
  description = "Workload Identity Pool Name"
  value       = google_iam_workload_identity_pool.github_actions_pool.name
}

output "workload_identity_provider_name" {
  description = "Workload Identity Provider Name"
  value       = google_iam_workload_identity_pool_provider.github_actions_provider.name
}

# IAM Custom Roles
output "cache_invalidator_role_name" {
  description = "Cache invalidator custom role name"
  value       = google_project_iam_custom_role.cache_invalidator.name
}

# Service Accounts
output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email"
  value       = google_service_account.github_actions_deployer.email
}

output "github_actions_service_account_name" {
  description = "GitHub Actions Service Account name"
  value       = google_service_account.github_actions_deployer.name
}

output "github_actions_service_account_key" {
  description = "GitHub Actions Service Account Key (base64 encoded)"
  value       = google_service_account_key.github_actions_key.private_key
  sensitive   = true
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

output "management_subnet_id" {
  description = "Management subnet ID"
  value       = google_compute_subnetwork.management_subnet.id
}

# Private Service Connection
output "private_ip_alloc_id" {
  description = "Private IP allocation ID for service networking"
  value       = google_compute_global_address.private_ip_alloc.id
}

# Cloud NAT
output "cloud_router_id" {
  description = "Cloud Router ID"
  value       = google_compute_router.main_router.id
}

output "cloud_nat_id" {
  description = "Cloud NAT ID"
  value       = google_compute_router_nat.main_nat.id
}

# ======================================
# Static IP Addresses
# ======================================

# API Static IP
output "api_static_ip_address" {
  description = "API Load Balancer static IP address"
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

