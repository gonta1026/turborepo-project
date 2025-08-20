# ======================================
# API Module Outputs
# ======================================

# ======================================
# Cloud Run Service
# ======================================

output "service_name" {
  description = "Cloud Run API service name"
  value       = google_cloud_run_v2_service.api_service.name
}

output "service_url" {
  description = "Cloud Run API service URL"
  value       = google_cloud_run_v2_service.api_service.uri
}

output "service_account_email" {
  description = "API Cloud Run service account email"
  value       = google_service_account.api_cloud_run_sa.email
}

# ======================================
# Load Balancer and SSL
# ======================================

output "load_balancer_ip" {
  description = "Static IP address for the API load balancer"
  value       = var.api_static_ip_address
}

output "https_load_balancer_url" {
  description = "HTTPS URL for the API with custom domain"
  value       = var.api_domain_name != "" ? "https://${var.api_domain_name}" : null
}

output "load_balancer_url" {
  description = "HTTP URL for the API load balancer (redirects to HTTPS)"
  value       = var.api_domain_name != "" ? "http://${var.api_static_ip_address}" : null
}

output "backend_service_name" {
  description = "Backend service name for the API load balancer"
  value       = google_compute_backend_service.api_backend_service.name
}

output "neg_name" {
  description = "Network Endpoint Group name for API Cloud Run service"
  value       = google_compute_region_network_endpoint_group.api_neg.name
}

# ======================================
# Database Resources
# ======================================

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

output "database_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.api_database_password.secret_id
}

# ======================================
# Database Connection Information
# ======================================

output "database_connection_info" {
  description = "Database connection information for application configuration"
  value = {
    host            = google_sql_database_instance.api_db_instance.private_ip_address
    port            = "5432"
    database        = google_sql_database.api_database.name
    user            = google_sql_user.api_user.name
    password_secret = google_secret_manager_secret.api_database_password.secret_id
  }
  sensitive = true
}

# ======================================
# DNS and Certificate
# ======================================

output "dns_records_required" {
  description = "API DNS records that need to be configured manually"
  value = var.api_domain_name != "" ? {
    domain = var.api_domain_name
    type   = "A"
    value  = var.api_static_ip_address
    ttl    = 300
  } : null
}

output "certificate_status" {
  description = "API SSL certificate status and information"
  value = var.api_domain_name != "" ? {
    certificate_id = google_certificate_manager_certificate.api_cert[0].id
    status_message = "Certificate configured - check GCP Console for detailed status"
    console_url    = "https://console.cloud.google.com/security/ccm/list/certificates?project=${var.project_id}"
    domain         = var.api_domain_name
  } : null
}