output "static_ip_address" {
  description = "Static IP address for DNS A record"
  value       = google_compute_global_address.dashboard_frontend.address
}

output "domain_name" {
  description = "Domain name to configure"
  value       = var.domain_name
}

# ======================================
# GitHub Secrets Configuration
# ======================================

output "github_secrets_configuration" {
  description = "Configuration values needed for GitHub Secrets"
  value = {
    PROD_GCS_BUCKET_NAME  = google_storage_bucket.dashboard_frontend.name
    PROD_CDN_URL_MAP_NAME = google_compute_url_map.dashboard_frontend.name
    # PROD_SERVICE_ACCOUNT と PROD_WIF_PROVIDER は shared/ から取得してください
  }
}

output "service_account_email" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions_deployer.email
}

output "bucket_name" {
  description = "Cloud Storage bucket name for deployment"
  value       = google_storage_bucket.dashboard_frontend.name
}

output "url_map_name" {
  description = "URL Map name for CDN cache invalidation"
  value       = google_compute_url_map.dashboard_frontend.name
}