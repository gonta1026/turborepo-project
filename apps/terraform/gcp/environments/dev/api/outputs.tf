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

# DNS Records Required (for manual DNS setup)
output "api_dns_records_required" {
  description = "DNS records that need to be configured manually"
  value = {
    domain = var.api_domain_name
    type   = "A"
    value  = data.terraform_remote_state.shared.outputs.api_static_ip_address
    ttl    = 300
  }
}