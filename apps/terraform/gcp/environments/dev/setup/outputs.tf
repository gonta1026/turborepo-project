output "project_id" {
  description = "GCP Project ID"
  value       = module.master.project_id
}

output "region" {
  description = "GCP region"
  value       = module.master.region
}

# 将来的なCloud Storage/CDN用のアウトプット（必要に応じて追加）
# output "bucket_url" {
#   description = "Cloud Storage bucket URL"
#   value       = module.master.bucket_url
# }

# output "website_url" {
#   description = "Website URL"
#   value       = module.master.website_url
# } 
