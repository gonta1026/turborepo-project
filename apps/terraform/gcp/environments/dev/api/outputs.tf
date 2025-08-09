# Outputs for API Environment
# 他のサービスや外部から参照される可能性のあるリソース情報を出力

# Database Connection Information
output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.api_db_instance.name
}

output "database_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.api_db_instance.connection_name
}

output "database_private_ip" {
  description = "Cloud SQL instance private IP address"
  value       = google_sql_database_instance.api_db_instance.private_ip_address
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.api_database.name
}

output "database_user" {
  description = "Database user name"
  value       = google_sql_user.api_user.name
  sensitive   = true
}

# Cloud Run Service Information
output "api_service_name" {
  description = "Cloud Run API service name"
  value       = google_cloud_run_v2_service.api_service.name
}

output "api_service_url" {
  description = "Cloud Run API service URL"
  value       = google_cloud_run_v2_service.api_service.uri
}

output "api_service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.api_cloud_run_sa.email
}

# DNS Records Required (for manual DNS setup)
output "api_dns_records_required" {
  description = "DNS records that need to be configured manually"
  value = {
    domain = var.api_domain_name
    type   = "CNAME"
    value  = "ghs.googlehosted.com." # 要らなそう
    ttl    = 300                     # 要らなそう
  }
}

output "certificate_status" {
  description = "SSL certificate status and information"
  value = {
    certificate_id = google_certificate_manager_certificate.api_cert.id
    status_message = "Certificate configured - check GCP Console for detailed status"
    console_url    = "https://console.cloud.google.com/security/ccm/list/certificates?project=${var.project_id}"
    domain         = var.api_domain_name
  }
}

# Load Balancer Information
output "load_balancer_ip" {
  description = "Static IP address for the API load balancer"
  value       = data.terraform_remote_state.shared.outputs.api_static_ip_address
}

output "https_load_balancer_url" {
  description = "HTTPS URL for the API with custom domain"
  value       = "https://${var.api_domain_name}"
}

output "load_balancer_url" {
  description = "HTTP URL for the API load balancer (redirects to HTTPS)"
  value       = "http://${data.terraform_remote_state.shared.outputs.api_static_ip_address}"
}

output "backend_service_name" {
  description = "Backend service name for the API load balancer"
  value       = google_compute_backend_service.api_backend_service.name
}

output "neg_name" {
  description = "Network Endpoint Group name for Cloud Run service"
  value       = google_compute_region_network_endpoint_group.api_neg.name
}
