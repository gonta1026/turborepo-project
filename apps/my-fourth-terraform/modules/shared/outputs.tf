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
  value       = google_compute_network.main_vpc.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main_vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main_vpc.self_link
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
  value       = google_compute_router.main_router.name
}

output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.main_router.id
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.main_nat.name
}

output "nat_id" {
  description = "ID of the Cloud NAT"
  value       = google_compute_router_nat.main_nat.id
}

output "vpc_connector_name" {
  description = "Name of the VPC Access Connector"
  value       = google_vpc_access_connector.main_connector.name
}

output "vpc_connector_id" {
  description = "ID of the VPC Access Connector"
  value       = google_vpc_access_connector.main_connector.id
}

output "vpc_connector_self_link" {
  description = "Self link of the VPC Access Connector"
  value       = google_vpc_access_connector.main_connector.self_link
}
