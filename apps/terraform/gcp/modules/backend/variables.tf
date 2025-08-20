# ======================================
# Backend Module Variables
# ======================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
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