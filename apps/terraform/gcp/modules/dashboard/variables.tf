# ======================================
# Dashboard Module Variables
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
# Bucket Configuration
# ======================================

variable "bucket_name" {
  description = "Name of the Cloud Storage bucket for dashboard static website hosting"
  type        = string
  default     = ""
}

variable "force_destroy_bucket" {
  description = "Force destroy the bucket (useful for development environments)"
  type        = bool
  default     = true
}

# ======================================
# Domain Configuration
# ======================================

variable "domain_name" {
  description = "Custom domain name for the CDN (optional)"
  type        = string
  default     = ""
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
# CDN Configuration
# ======================================

variable "enable_cdn" {
  description = "Enable CDN for the backend bucket"
  type        = bool
  default     = true
}

variable "cdn_cache_mode" {
  description = "CDN cache mode"
  type        = string
  default     = "CACHE_ALL_STATIC"
}

variable "cdn_default_ttl" {
  description = "CDN default TTL in seconds"
  type        = number
  default     = 3600
}

variable "cdn_client_ttl" {
  description = "CDN client TTL in seconds"
  type        = number
  default     = 7200
}

variable "cdn_max_ttl" {
  description = "CDN max TTL in seconds"
  type        = number
  default     = 10800
}

variable "cdn_negative_caching" {
  description = "Enable CDN negative caching"
  type        = bool
  default     = true
}

variable "cdn_serve_while_stale" {
  description = "CDN serve while stale time in seconds"
  type        = number
  default     = 86400
}