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

# Dashboard Cloud Storage設定
variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for dashboard static website hosting"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Custom domain name for the CDN (optional)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
}

# GitHub Actions Workload Identity Federation設定
variable "github_repository" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string
  default     = "gonta1026/turborepo-project"
}
