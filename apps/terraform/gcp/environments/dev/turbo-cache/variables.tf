variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
}

variable "turbo_token" {
  description = "Turbo cache server authentication token"
  type        = string
  sensitive   = true
}
