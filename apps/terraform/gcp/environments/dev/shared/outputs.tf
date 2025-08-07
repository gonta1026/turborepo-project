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
