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

