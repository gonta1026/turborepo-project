# プロジェクト基本設定
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "terraform-gcp-466623"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

# Cloud Storage/CDN用の設定
variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for static website hosting"
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
  default = {
    environment = "dev"
    managed_by  = "terraform"
    purpose     = "dashboard-hosting"
  }
}

# IAM関連の変数
variable "dev_team_group" {
  description = "Development team Google group email"
  type        = string
  default     = "terraform-dev-team@googlegroups.com"
}

