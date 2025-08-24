# ======================================
# TERRAFORM VARIABLES - Dev Environment
# 全サービス共通の変数定義ファイル
# ======================================

# ======================================
# プロジェクト基本設定
# ======================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  # default     = {}
}

# ======================================
# Shared Resources - IAM & GitHub Actions設定
# ======================================

variable "dev_team_group" {
  description = "Development team Google group email"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository for Workload Identity Federation (format: owner/repo)"
  type        = string
}

# ======================================
# Dashboard設定
# ======================================

# variable "bucket_name" {
#   description = "Name of the Cloud Storage bucket for dashboard static website hosting"
#   type        = string
#   default     = ""
# }

# variable "domain_name" {
#   description = "Custom domain name for the CDN (optional)"
#   type        = string
# default     = ""
# }

# ======================================
# API設定
# ======================================

# variable "api_domain_name" {
#   description = "Custom domain name for the API service (e.g., dev.api.my-learn-iac-sample.site)"
#   type        = string
# default     = ""
# }

# ======================================
# Database設定
# ======================================

# variable "database_name" {
#   description = "Name of the database"
#   type        = string
#   # default     = "api_db"
# }

# variable "database_user" {
#   description = "Database user name"
#   type        = string
#   # default     = "api_user"
# }

# ======================================
# CORS設定
# ======================================

# variable "dashboard_client_url" {
#   description = "Dashboard client URL for CORS (e.g., https://dev.dashboard.my-learn-iac-sample.site)"
#   type        = string
# }
