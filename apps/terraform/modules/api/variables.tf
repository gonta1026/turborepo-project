# ======================================
# API Module Variables
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

# ======================================
# Network Dependencies
# ======================================

variable "vpc_connector_id" {
  description = "VPC Access Connector ID for Cloud Run services"
  type        = string
}

variable "api_static_ip_address" {
  description = "Static IP address for API load balancer"
  type        = string
}

# ======================================
# Certificate Dependencies
# ======================================

variable "shared_certificate_map_name" {
  description = "Shared certificate map name from shared module"
  type        = string
}

variable "shared_certificate_map_id" {
  description = "Shared certificate map ID from shared module"
  type        = string
}

# ======================================
# Network Dependencies (for Database)
# ======================================

variable "vpc_network_id" {
  description = "VPC network ID for Cloud SQL"
  type        = string
}

variable "private_vpc_connection" {
  description = "Private VPC connection dependency"
  type        = string
}

# ======================================
# Database Configuration
# ======================================

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

variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_availability_type" {
  description = "Cloud SQL availability type"
  type        = string
  default     = "ZONAL"
  
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.db_availability_type)
    error_message = "Availability type must be ZONAL or REGIONAL."
  }
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 10
}

variable "deletion_protection" {
  description = "Enable deletion protection for Cloud SQL instance"
  type        = bool
  default     = true
}

# ======================================
# Domain Configuration
# ======================================

variable "api_domain_name" {
  description = "Custom domain name for the API service (optional)"
  type        = string
  default     = ""
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins for the API"
  type        = string
  default     = "*"
}

# ======================================
# Cloud Run Configuration
# ======================================

variable "container_port" {
  description = "Container port for Cloud Run service"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service"
  type        = string
  default     = "512Mi"
}

variable "startup_cpu_boost" {
  description = "Enable startup CPU boost for Cloud Run service"
  type        = bool
  default     = true
}

variable "min_instance_count" {
  description = "Minimum number of instances for Cloud Run service"
  type        = number
  default     = 0
}

variable "max_instance_count" {
  description = "Maximum number of instances for Cloud Run service"
  type        = number
  default     = 10
}

# ======================================
# Health Check Configuration
# ======================================

variable "health_check_path" {
  description = "Health check path for Cloud Run service"
  type        = string
  default     = "/health"
}

variable "startup_probe_initial_delay" {
  description = "Initial delay for startup probe in seconds"
  type        = number
  default     = 10
}

variable "startup_probe_period" {
  description = "Period for startup probe in seconds"
  type        = number
  default     = 10
}

variable "startup_probe_timeout" {
  description = "Timeout for startup probe in seconds"
  type        = number
  default     = 5
}

variable "startup_probe_failure_threshold" {
  description = "Failure threshold for startup probe"
  type        = number
  default     = 3
}

variable "liveness_probe_period" {
  description = "Period for liveness probe in seconds"
  type        = number
  default     = 30
}

variable "liveness_probe_timeout" {
  description = "Timeout for liveness probe in seconds"
  type        = number
  default     = 5
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
  default     = 3
}

# ======================================
# Load Balancer Configuration
# ======================================

variable "enable_backend_logging" {
  description = "Enable backend service logging"
  type        = bool
  default     = true
}