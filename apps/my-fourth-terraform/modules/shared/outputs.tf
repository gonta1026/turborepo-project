# ======================================
# IAM Resources
# ======================================

output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email"
  value       = google_service_account.github_actions_deployer.email
}

output "github_actions_service_account_name" {
  description = "GitHub Actions Service Account name"
  value       = google_service_account.github_actions_deployer.name
}

# ======================================
# Workload Identity Federation
# ======================================

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
}

output "workload_identity_provider_name" {
  description = "Workload Identity Provider name"
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}
output "terraform_state_bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "URL of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.url
}
output "terraform_state_bucket_self_link" {
  description = "Self link of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.self_link
}

# ======================================
# Network Resources
# ======================================

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.api_vpc.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.api_vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.api_vpc.self_link
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.public_subnet.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = google_compute_subnetwork.public_subnet.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.api_router.name
}

output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.api_router.id
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.api_nat.name
}

output "nat_id" {
  description = "ID of the Cloud NAT"
  value       = google_compute_router_nat.api_nat.id
}

output "vpc_connector_name" {
  description = "Name of the VPC Access Connector"
  value       = google_vpc_access_connector.api_connector.name
}

output "vpc_connector_id" {
  description = "ID of the VPC Access Connector"
  value       = google_vpc_access_connector.api_connector.id
}

output "vpc_connector_self_link" {
  description = "Self link of the VPC Access Connector"
  value       = google_vpc_access_connector.api_connector.self_link
}

output "api_static_ip_name" {
  description = "Name of the API Static IP"
  value       = google_compute_global_address.api_static_ip.name
}

output "api_static_ip_address" {
  description = "Address of the API Static IP"
  value       = google_compute_global_address.api_static_ip.address
}

# ======================================
# Certificate Manager
# ======================================

output "certificate_map_name" {
  description = "Name of the Certificate Manager map"
  value       = google_certificate_manager_certificate_map.api_cert_map.name
}

output "certificate_map_id" {
  description = "ID of the Certificate Manager map"
  value       = google_certificate_manager_certificate_map.api_cert_map.id
}

# ======================================
# Artifact Registry
# ======================================

output "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository for API service"
  value       = google_artifact_registry_repository.api_repo.repository_id
}

# ======================================
# Database Outputs
# ======================================

output "database_user" {
  description = "Name of the database user"
  value       = google_sql_user.api_user.name
}

output "database_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.api_database_password.secret_id
}

# ======================================
# GitHub Actions用のOutputs
# ======================================

output "WIF_PROVIDER" {
  description = "Workload Identity Federation Provider name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}

output "SERVICE_ACCOUNT" {
  description = "Service Account email for GitHub Actions"
  value       = google_service_account.github_actions_deployer.email
}

output "DB_PASSWORD" {
  description = "Database password secret ID for GitHub Actions"
  value       = google_secret_manager_secret.api_database_password.secret_id
  sensitive   = true
}

# ======================================
# Dashboard用のOutputs
# ======================================

output "GCS_BUCKET_NAME" {
  description = "Dashboard GCS bucket name for GitHub Actions"
  value       = google_storage_bucket.dashboard_bucket.name
}

output "CDN_URL_MAP_NAME" {
  description = "Dashboard URL Map name for GitHub Actions"
  value       = google_compute_url_map.dashboard_url_map.name
}

output "dashboard_static_ip_address" {
  description = "Dashboard static IP address"
  value       = google_compute_global_address.dashboard_static_ip.address
}

output "dashboard_static_ip_name" {
  description = "Dashboard static IP name"
  value       = google_compute_global_address.dashboard_static_ip.name
}

output "dashboard_bucket_url" {
  description = "Dashboard GCS bucket URL"
  value       = google_storage_bucket.dashboard_bucket.url
}
