# ======================================
# Dashboard Module Outputs
# ======================================

# ======================================
# Cloud Storage
# ======================================

output "bucket_name" {
  description = "Dashboard website storage bucket name"
  value       = google_storage_bucket.website_bucket.name
}

output "bucket_url" {
  description = "Dashboard website storage bucket URL"
  value       = google_storage_bucket.website_bucket.url
}

output "bucket_region" {
  description = "Dashboard website storage bucket region"
  value       = google_storage_bucket.website_bucket.location
}

output "website_url" {
  description = "Dashboard static website URL"
  value       = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
}

# ======================================
# Load Balancer
# ======================================

output "static_ip_address" {
  description = "Dashboard static IP address for the load balancer"
  value       = google_compute_global_address.website_ip.address
}

output "load_balancer_ip" {
  description = "Dashboard load balancer IP address"
  value       = google_compute_global_forwarding_rule.website_http_forwarding_rule.ip_address
}

output "backend_bucket_name" {
  description = "Dashboard CDN backend bucket name"
  value       = google_compute_backend_bucket.website_backend.name
}

output "url_map_name" {
  description = "Dashboard URL map name"
  value       = google_compute_url_map.website_url_map.name
}

output "load_balancer_url" {
  description = "Dashboard load balancer URL (HTTP)"
  value       = "http://${google_compute_global_forwarding_rule.website_http_forwarding_rule.ip_address}"
}

# ======================================
# HTTPS and SSL
# ======================================

output "https_load_balancer_url" {
  description = "Dashboard load balancer URL (HTTPS)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : null
}

output "certificate_status" {
  description = "Dashboard SSL certificate status and information"
  value = var.domain_name != "" ? {
    certificate_id = google_certificate_manager_certificate.website_cert[0].id
    status_message = "Certificate configured - check GCP Console for detailed status"
    console_url    = "https://console.cloud.google.com/security/ccm/list/certificates?project=${var.project_id}"
    domain         = var.domain_name
  } : null
}

# ======================================
# DNS Configuration
# ======================================

output "dns_records_required" {
  description = "Dashboard DNS records that need to be configured at your domain provider"
  value = var.domain_name != "" ? {
    domain = var.domain_name
    records = [
      {
        type  = "A"
        name  = "${var.environment}.dashboard"
        value = google_compute_global_address.website_ip.address
        ttl   = 300
      }
    ]
    instructions = {
      step1 = "Create an A record pointing ${var.environment}.dashboard.${split(".", var.domain_name)[1]}.${split(".", var.domain_name)[2]} to ${google_compute_global_address.website_ip.address}"
      step2 = "Wait for DNS propagation (can take up to 48 hours)"
      step3 = "Run 'terraform apply' again to provision the SSL certificate"
      step4 = "Certificate provisioning may take 10-60 minutes after DNS is configured"
    }
  } : null
}

output "dns_verification_commands" {
  description = "Commands to verify dashboard DNS configuration"
  value = var.domain_name != "" ? [
    "nslookup ${var.domain_name}",
    "dig ${var.domain_name}",
    "curl -I https://${var.domain_name}"
  ] : []
}