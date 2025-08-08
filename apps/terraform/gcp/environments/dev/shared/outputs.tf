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

