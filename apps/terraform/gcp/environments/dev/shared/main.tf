terraform {
  required_version = ">= 1.12.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ======================================
# Artifact Registry
# ======================================

# Artifact Registry Repository for API Service
resource "google_artifact_registry_repository" "api_service" {
  location      = var.region
  repository_id = "api-service"
  description   = "Docker repository for API service images"
  format        = "DOCKER"
}

# Artifact Registry Repository for Dashboard Service
resource "google_artifact_registry_repository" "dashboard_service" {
  location      = var.region
  repository_id = "dashboard-service"
  description   = "Docker repository for Dashboard service images"
  format        = "DOCKER"
}
