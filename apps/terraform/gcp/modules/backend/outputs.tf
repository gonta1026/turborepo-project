# ======================================
# Backend Module Outputs
# ======================================

# ======================================
# Terraform State Management
# ======================================

output "terraform_state_bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "URL of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.url
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
    host     = google_sql_database_instance.api_db_instance.private_ip_address
    port     = "5432"
    database = google_sql_database.api_database.name
    user     = google_sql_user.api_user.name
    password_secret = google_secret_manager_secret.api_database_password.secret_id
  }
  sensitive = true
}