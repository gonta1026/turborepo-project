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

# ======================================
# Load Balancer outputs
# ======================================

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = google_compute_global_forwarding_rule.website_http_forwarding_rule.ip_address
}

output "backend_bucket_name" {
  description = "CDN backend bucket name"
  value       = google_compute_backend_bucket.website_backend.name
}

output "url_map_name" {
  description = "URL map name"
  value       = google_compute_url_map.website_url_map.name
}

output "load_balancer_url" {
  description = "Load balancer URL (HTTP)"
  value       = "http://${google_compute_global_forwarding_rule.website_http_forwarding_rule.ip_address}"
}
