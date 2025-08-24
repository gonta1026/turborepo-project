# ======================================
# Shared Module Outputs
# ======================================

# ======================================
# Workload Identity Federation
# ======================================

# output "workload_identity_pool_id" {
#   description = "Workload Identity Pool ID"
#   value       = google_iam_workload_identity_pool.github_actions_pool.id
# }

# output "workload_identity_pool_name" {
#   description = "Workload Identity Pool Name"
#   value       = google_iam_workload_identity_pool.github_actions_pool.name
# }

# output "workload_identity_provider_name" {
#   description = "Workload Identity Provider Name"
#   value       = google_iam_workload_identity_pool_provider.github_actions_provider.name
# }

# ======================================
# Network Infrastructure
# ======================================

# output "vpc_network_id" {
#   description = "Main VPC network ID"
#   value       = google_compute_network.main_vpc.id
# }

# output "vpc_network_name" {
#   description = "Main VPC network name"
#   value       = google_compute_network.main_vpc.name
# }

# output "public_subnet_id" {
#   description = "Public subnet ID"
#   value       = google_compute_subnetwork.public_subnet.id
# }

# output "private_subnet_id" {
#   description = "Private subnet ID"
#   value       = google_compute_subnetwork.private_subnet.id
# }

# output "management_subnet_id" {
#   description = "Management subnet ID"
#   value       = google_compute_subnetwork.management_subnet.id
# }

# output "private_ip_alloc_id" {
#   description = "Private IP allocation ID for service networking"
#   value       = google_compute_global_address.private_ip_alloc.id
# }

# output "private_vpc_connection" {
#   description = "Private VPC connection for Cloud SQL"
#   value       = google_service_networking_connection.private_vpc_connection.id
# }

# output "vpc_connector_id" {
#   description = "VPC Access Connector ID for Cloud Run services"
#   value       = google_vpc_access_connector.main_connector.id
# }

# output "vpc_connector_name" {
#   description = "VPC Access Connector name"
#   value       = google_vpc_access_connector.main_connector.name
# }

# ======================================
# IAM Resources
# ======================================

# output "github_actions_service_account_email" {
#   description = "GitHub Actions Service Account email"
#   value       = google_service_account.github_actions_deployer.email
# }

# output "github_actions_service_account_name" {
#   description = "GitHub Actions Service Account name"
#   value       = google_service_account.github_actions_deployer.name
# }

# output "github_actions_service_account_key" {
#   description = "GitHub Actions Service Account Key (base64 encoded)"
#   value       = google_service_account_key.github_actions_key.private_key
#   sensitive   = true
# }

# output "cache_invalidator_role_name" {
#   description = "Cache invalidator custom role name"
#   value       = google_project_iam_custom_role.cache_invalidator.name
# }


# ======================================
# Static IP Addresses
# ======================================

# output "api_static_ip_address" {
#   description = "API Load Balancer static IP address"
#   value       = google_compute_global_address.api_ip.address
# }

# output "api_static_ip_id" {
#   description = "API Load Balancer static IP resource ID"
#   value       = google_compute_global_address.api_ip.id
# }

# ======================================
# Terraform State Management
# ======================================

# output "terraform_state_bucket_name" {
#   description = "Name of the GCS bucket for Terraform state"
#   value       = google_storage_bucket.terraform_state.name
# }

# output "terraform_state_bucket_url" {
#   description = "URL of the GCS bucket for Terraform state"
#   value       = google_storage_bucket.terraform_state.url
# }

# ======================================
# Certificate Management
# ======================================

# output "shared_certificate_map_name" {
#   description = "Shared Certificate Map name"
#   value       = google_certificate_manager_certificate_map.shared_cert_map.name
# }

# output "shared_certificate_map_id" {
#   description = "Shared Certificate Map ID"
#   value       = google_certificate_manager_certificate_map.shared_cert_map.id
# }

# ======================================
# Artifact Registry
# ======================================

# output "api_service_repository_id" {
#   description = "API Service Artifact Registry repository ID"
#   value       = google_artifact_registry_repository.api_service.id
# }

# output "api_service_repository_name" {
#   description = "API Service Artifact Registry repository name"
#   value       = google_artifact_registry_repository.api_service.name
# }

# output "dashboard_service_repository_id" {
#   description = "Dashboard Service Artifact Registry repository ID"
#   value       = google_artifact_registry_repository.dashboard_service.id
# }

# output "dashboard_service_repository_name" {
#   description = "Dashboard Service Artifact Registry repository name"
#   value       = google_artifact_registry_repository.dashboard_service.name
# }
