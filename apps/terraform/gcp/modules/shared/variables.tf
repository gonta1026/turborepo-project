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

variable "environment" {
  description = "Environment name (dev, staging, prod)"
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
  description = "GitHub repository for Workload Identity Federation (format: owner/repo)"
  type        = string
}