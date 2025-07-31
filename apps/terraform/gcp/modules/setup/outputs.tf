# 将来的なCloud Storage/CDN用のアウトプット（必要に応じて追加）

# bucket_url = google_storage_bucket.website_bucket.url
# cdn_ip_address = google_compute_global_address.cdn_ip.address
# website_url = "https://${var.domain_name}"

# 現在は基本的なプロジェクト情報のみをアウトプット
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
} 
