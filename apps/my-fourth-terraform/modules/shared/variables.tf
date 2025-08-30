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

# ======================================
# ファイアウォール設定
# ======================================
# 環境別で明示的に設定することでセキュリティポリシーを明確化

variable "firewall_http_source_ranges" {
  description = "Source IP ranges allowed for HTTP/HTTPS traffic"
  type        = list(string)
  # defaultなし - 環境別で明示的に設定必須
}

variable "firewall_health_check_ports" {
  description = "Ports allowed for health check traffic"
  type        = list(string)
  # defaultなし - 環境別で明示的に設定必須
}

variable "firewall_internal_tcp_ports" {
  description = "TCP ports allowed for internal communication"
  type        = list(string)
  # defaultなし - 環境別で明示的に設定必須
}

variable "firewall_internal_udp_ports" {
  description = "UDP ports allowed for internal communication"
  type        = list(string)
  # defaultなし - 環境別で明示的に設定必須
}

variable "firewall_ssh_count" {
  description = "Count for SSH firewall rule (1 to create, 0 to skip)"
  type        = number
  # defaultなし - 環境別で明示的に設定必須
}

variable "firewall_ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  # defaultなし - 環境別で明示的に設定必須
}

# ======================================
# インフラストラクチャ設定
# ======================================

variable "ssl_certificate_domain" {
  description = "Primary domain for SSL certificate"
  type        = string
  # defaultなし - 環境別で明示的に設定必須
}


variable "private_service_connection_count" {
  description = "Count for Private Service Connection (1 to create, 0 to skip)"
  type        = number
  # defaultなし - 環境別で明示的に設定必須
}

variable "private_service_connection_prefix" {
  description = "Prefix length for Private Service Connection IP allocation"
  type        = number
  # defaultなし - 環境別で明示的に設定必須
}

# ======================================
# データベース設定
# ======================================

variable "database_deletion_protection" {
  description = "Enable deletion protection for database instance"
  type        = bool
}

variable "database_tier" {
  description = "Machine type for Cloud SQL instance"
  type        = string
}

variable "database_availability_type" {
  description = "Availability type for Cloud SQL instance (ZONAL or REGIONAL)"
  type        = string
}

variable "database_disk_size" {
  description = "Disk size for Cloud SQL instance in GB"
  type        = number
}

variable "database_backup_retained_count" {
  description = "Number of backups to retain"
  type        = number
}

variable "database_backup_enabled" {
  description = "Enable or disable database backups"
  type        = bool
}

variable "database_transaction_log_retention_days" {
  description = "Transaction log retention days (1-7 for PostgreSQL)"
  type        = number
}

# ======================================
# Cloud Run設定
# ======================================

variable "cloudrun_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
}

variable "cloudrun_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
}

variable "cloudrun_image" {
  description = "Container image for Cloud Run service"
  type        = string
}

variable "cloudrun_cpu_limit" {
  description = "CPU limit for Cloud Run container"
  type        = string
}

variable "cloudrun_memory_limit" {
  description = "Memory limit for Cloud Run container"
  type        = string
}

variable "cloudrun_port" {
  description = "Container port for Cloud Run service"
  type        = number
}

variable "cloudrun_environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "cloudrun_health_check_path" {
  description = "Health check path for Cloud Run service"
  type        = string
}

variable "cloudrun_startup_probe_initial_delay" {
  description = "Initial delay for startup probe in seconds"
  type        = number
}

variable "cloudrun_startup_probe_timeout" {
  description = "Timeout for startup probe in seconds"
  type        = number
}

variable "cloudrun_startup_probe_period" {
  description = "Period for startup probe in seconds"
  type        = number
}

variable "cloudrun_startup_probe_failure_threshold" {
  description = "Failure threshold for startup probe"
  type        = number
}

variable "cloudrun_liveness_probe_initial_delay" {
  description = "Initial delay for liveness probe in seconds"
  type        = number
}

variable "cloudrun_liveness_probe_timeout" {
  description = "Timeout for liveness probe in seconds"
  type        = number
}

variable "cloudrun_liveness_probe_period" {
  description = "Period for liveness probe in seconds"
  type        = number
}

variable "cloudrun_liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
}
