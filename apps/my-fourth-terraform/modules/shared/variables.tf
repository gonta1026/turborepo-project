# ======================================
# Shared Module Variables
# ======================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}


variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
}

variable "dev_team_group" {
  description = "Development team Google group email"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in format 'owner/repo' for Workload Identity Federation"
  type        = string
}
# VPC Access Connector設定
variable "vpc_connector_min_instances" {
  description = "Minimum number of instances for VPC Access Connector"
  type        = number
}

variable "vpc_connector_max_instances" {
  description = "Maximum number of instances for VPC Access Connector"
  type        = number
  default     = 3
}

variable "vpc_connector_machine_type" {
  description = "Machine type for VPC Access Connector"
  type        = string
  default     = "e2-micro"
}

variable "vpc_connector_min_throughput" {
  description = "Minimum throughput for VPC Access Connector (Mbps)"
  type        = number
  default     = 200
}

variable "vpc_connector_max_throughput" {
  description = "Maximum throughput for VPC Access Connector (Mbps)"
  type        = number
  default     = 300
}

# ログ設定
variable "subnet_flow_sampling" {
  description = "Flow log sampling rate for subnets"
  type        = number
  default     = 0.5
  validation {
    condition     = var.subnet_flow_sampling >= 0.0 && var.subnet_flow_sampling <= 1.0
    error_message = "Flow sampling rate must be between 0.0 and 1.0."
  }
}

variable "nat_log_filter" {
  description = "Cloud NAT log filter"
  type        = string
  default     = "ERRORS_ONLY"
  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.nat_log_filter)
    error_message = "NAT log filter must be one of: ERRORS_ONLY, TRANSLATIONS_ONLY, ALL."
  }
}

# GCS Bucket設定
variable "bucket_lifecycle_age_days" {
  description = "Age in days for GCS bucket lifecycle rule"
  type        = number
  default     = 30
}
