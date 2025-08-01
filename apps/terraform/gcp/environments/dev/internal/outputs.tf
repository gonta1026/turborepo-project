output "project_id" {
  description = "GCP Project ID"
  value       = module.master.project_id
}

output "region" {
  description = "GCP region"
  value       = module.master.region
}

# Cloud Storage/CDN outputs
output "bucket_name" {
  description = "Cloud Storage bucket name"
  value       = module.master.bucket_name
}

output "bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = module.master.bucket_url
}

output "bucket_region" {
  description = "Cloud Storage bucket region"
  value       = module.master.bucket_region
}

output "website_url" {
  description = "Website URL"
  value       = module.master.website_url
}
