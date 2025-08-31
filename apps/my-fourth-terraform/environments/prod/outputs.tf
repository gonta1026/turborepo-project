# ======================================
# Prod Environment Outputs - Module-based
# ======================================
# modules/からの出力を集約

# ======================================
# Project Information
# ======================================

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}
# ======================================
# Network Resources
# ======================================

output "api_static_ip_name" {
  description = "Name of the API Static IP"
  value       = module.shared.api_static_ip_name
}

output "api_static_ip_address" {
  description = "Address of the API Static IP"
  value       = module.shared.api_static_ip_address
}

# ======================================
# GitHub Actions用のOutputs
# ======================================

output "WIF_PROVIDER" {
  description = "Workload Identity Federation Provider name for GitHub Actions"
  value       = module.shared.WIF_PROVIDER
}

output "SERVICE_ACCOUNT" {
  description = "Service Account email for GitHub Actions"
  value       = module.shared.SERVICE_ACCOUNT
}

output "DB_PASSWORD" {
  description = "Database password secret ID for GitHub Actions"
  value       = module.shared.DB_PASSWORD
  sensitive   = true
}

# ======================================
# Dashboard用のOutputs
# ======================================

output "GCS_BUCKET_NAME" {
  description = "Dashboard GCS bucket name for GitHub Actions"
  value       = module.shared.GCS_BUCKET_NAME
}

output "CDN_URL_MAP_NAME" {
  description = "Dashboard URL Map name for GitHub Actions"
  value       = module.shared.CDN_URL_MAP_NAME
}

output "dashboard_static_ip_address" {
  description = "Dashboard static IP address"
  value       = module.shared.dashboard_static_ip_address
}

output "dashboard_static_ip_name" {
  description = "Dashboard static IP name"
  value       = module.shared.dashboard_static_ip_name
}

