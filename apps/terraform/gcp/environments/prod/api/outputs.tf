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

# Certificate Information
output "api_certificate_id" {
  description = "API SSL certificate ID"
  value       = google_certificate_manager_certificate.api_cert.id
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

# Secret Manager Information
output "db_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}