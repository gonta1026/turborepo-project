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

# ======================================
# HTTPS and Certificate Manager outputs
# ======================================

output "static_ip_address" {
  description = "Static IP address for the load balancer"
  value       = google_compute_global_address.website_ip.address
}

output "https_load_balancer_url" {
  description = "Load balancer URL (HTTPS)"
  value       = "https://${var.domain_name}"
}

output "certificate_status" {
  description = "SSL certificate status and information"
  value = {
    certificate_id = google_certificate_manager_certificate.website_cert.id
    status_message = "Certificate configured - check GCP Console for detailed status"
    console_url    = "https://console.cloud.google.com/security/ccm/list/certificates?project=${var.project_id}"
    domain         = var.domain_name
  }
}

output "certificate_map_id" {
  description = "Certificate Map ID"
  value       = google_certificate_manager_certificate_map.website_cert_map.id
}

# ======================================
# DNS Configuration Information
# ======================================

output "dns_records_required" {
  description = "DNS records that need to be configured at your domain provider"
  value = {
    domain = var.domain_name
    records = [
      {
        type  = "A"
        name  = "dev.dashboard" # subdomain part
        value = google_compute_global_address.website_ip.address
        ttl   = 300
      }
    ]
    instructions = {
      step1 = "Create an A record pointing dev.dashboard.my-learn-iac-sample.site to ${google_compute_global_address.website_ip.address}"
      step2 = "Wait for DNS propagation (can take up to 48 hours)"
      step3 = "Run 'terraform apply' again to provision the SSL certificate"
      step4 = "Certificate provisioning may take 10-60 minutes after DNS is configured"
    }
  }
}

output "dns_verification_commands" {
  description = "Commands to verify DNS configuration"
  value = [
    "nslookup ${var.domain_name}",
    "dig ${var.domain_name}",
    "curl -I https://${var.domain_name}"
  ]
}

# ======================================
# Service Account outputs
# ======================================

output "service_account_email" {
  description = "Service account email for GitHub Actions"
  value       = data.terraform_remote_state.shared.outputs.github_actions_service_account_email
}
output "github_actions_configuration" {
  description = "Configuration information for GitHub Actions"
  value = {
    workload_identity_provider = data.terraform_remote_state.shared.outputs.workload_identity_provider_name
    service_account            = data.terraform_remote_state.shared.outputs.github_actions_service_account_email
    project_id                 = var.project_id
    repository                 = var.github_repository
  }
}

# Service Account Key is managed in shared/iam.tf
output "service_account_key" {
  description = "Service account key for GitHub Actions (base64 encoded) - managed in shared"
  value       = data.terraform_remote_state.shared.outputs.github_actions_service_account_key
  sensitive   = true
}
