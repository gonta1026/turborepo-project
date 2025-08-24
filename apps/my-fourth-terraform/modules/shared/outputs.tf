# ======================================
# IAM Resources
# ======================================

output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email"
  value       = google_service_account.github_actions_deployer.email
}

output "github_actions_service_account_name" {
  description = "GitHub Actions Service Account name"
  value       = google_service_account.github_actions_deployer.name
}
output "terraform_state_bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "URL of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.url
}
output "terraform_state_bucket_self_link" {
  description = "Self link of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.self_link
}
