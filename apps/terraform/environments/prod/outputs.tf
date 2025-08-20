# ======================================
# Prod Environment Outputs - Module-based
# ======================================
# modules/からの出力を集約

# ======================================
# Project Information
# ======================================

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

# ======================================
# Shared Module Outputs
# ======================================

output "vpc_network_name" {
  description = "Main VPC network name"
  value       = module.shared.vpc_network_name
}

output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email"
  value       = module.shared.github_actions_service_account_email
}

output "api_static_ip_address" {
  description = "API Load Balancer static IP address"
  value       = module.shared.api_static_ip_address
}

# ======================================
# Backend Module Outputs
# ======================================

output "terraform_state_bucket_name" {
  description = "Name of the GCS bucket for Terraform state"
  value       = module.backend.terraform_state_bucket_name
}

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.backend.database_instance_name
}

output "database_private_ip" {
  description = "Cloud SQL instance private IP address"
  value       = module.backend.database_private_ip
}

# ======================================
# Dashboard Module Outputs
# ======================================

output "dashboard_bucket_name" {
  description = "Dashboard website storage bucket name"
  value       = module.dashboard.bucket_name
}

output "dashboard_static_ip_address" {
  description = "Dashboard static IP address for the load balancer"
  value       = module.dashboard.static_ip_address
}

output "dashboard_load_balancer_url" {
  description = "Dashboard load balancer URL (HTTP)"
  value       = module.dashboard.load_balancer_url
}

output "dashboard_https_load_balancer_url" {
  description = "Dashboard load balancer URL (HTTPS)"
  value       = module.dashboard.https_load_balancer_url
}

output "dashboard_dns_records_required" {
  description = "Dashboard DNS records that need to be configured at your domain provider"
  value       = module.dashboard.dns_records_required
}

# ======================================
# API Module Outputs
# ======================================

output "api_service_name" {
  description = "Cloud Run API service name"
  value       = module.api.service_name
}

output "api_service_url" {
  description = "Cloud Run API service URL"
  value       = module.api.service_url
}

output "api_https_load_balancer_url" {
  description = "HTTPS URL for the API with custom domain"
  value       = module.api.https_load_balancer_url
}

output "api_dns_records_required" {
  description = "API DNS records that need to be configured manually"
  value       = module.api.dns_records_required
}

# ======================================
# Configuration Summary
# ======================================

output "deployment_summary" {
  description = "Summary of deployed resources for prod environment"
  value = {
    shared = {
      vpc_network = module.shared.vpc_network_name
      static_ip   = module.shared.api_static_ip_address
    }
    backend = {
      database_instance = module.backend.database_instance_name
      state_bucket      = module.backend.terraform_state_bucket_name
    }
    dashboard = {
      bucket_name = module.dashboard.bucket_name
      static_ip   = module.dashboard.static_ip_address
      https_url   = module.dashboard.https_load_balancer_url
    }
    api = {
      service_name = module.api.service_name
      service_url  = module.api.service_url
      https_url    = module.api.https_load_balancer_url
    }
  }
}
