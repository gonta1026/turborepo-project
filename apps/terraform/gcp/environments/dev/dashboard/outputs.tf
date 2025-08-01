# ======================================
# Cloud Storage outputs
# ======================================

output "bucket_name" {
  description = "Storage bucket name"
  value       = google_storage_bucket.website_bucket.name
}

output "bucket_url" {
  description = "Storage bucket URL"
  value       = google_storage_bucket.website_bucket.url
}

output "bucket_region" {
  description = "Storage bucket region"
  value       = google_storage_bucket.website_bucket.location
}

output "website_url" {
  description = "Static website URL"
  value       = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
}
