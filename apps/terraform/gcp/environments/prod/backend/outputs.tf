# バケット名の出力（他のモジュールで参照可能）
output "terraform_state_bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

# バケットURLの出力（他のモジュールで参照可能）
output "terraform_state_bucket_url" {
  description = "URL of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.url
}
