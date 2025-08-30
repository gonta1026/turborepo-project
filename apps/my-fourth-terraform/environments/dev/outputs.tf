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
# Workload Identity Federation
# ======================================

output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email for WIF"
  value       = module.shared.github_actions_service_account_email
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = module.shared.workload_identity_pool_id
}

output "workload_identity_provider_name" {
  description = "Workload Identity Provider name"
  value       = module.shared.workload_identity_provider_name
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

