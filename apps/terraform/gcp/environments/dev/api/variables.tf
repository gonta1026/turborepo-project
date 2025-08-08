# プロジェクト基本設定
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
  default     = {}
}

# API Configuration
variable "api_domain_name" {
  description = "Custom domain name for the API service (e.g., dev.api.my-learn-iac-sample.site)"
  type        = string
  default     = ""
}

# Database Configuration
variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "api_db"
}

variable "database_user" {
  description = "Database user name"
  type        = string
  default     = "api_user"
}