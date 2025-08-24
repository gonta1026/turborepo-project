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
