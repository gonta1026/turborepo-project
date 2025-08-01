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

# Internal固有の変数
variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for internal static website hosting"
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
