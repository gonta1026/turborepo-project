# Shared Infrastructure Configuration for Production Environment

terraform {
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
# Docker images for API service are stored here
resource "google_artifact_registry_repository" "api_service" {
  location      = var.region
  repository_id = "api-service"
  description   = "Docker repository for API service images"
  format        = "DOCKER"
}

# Artifact Registry Repository for Dashboard Service  
# Docker images for Dashboard service are stored here
resource "google_artifact_registry_repository" "dashboard_service" {
  location      = var.region
  repository_id = "dashboard-service"
  description   = "Docker repository for Dashboard service images"
  format        = "DOCKER"
}

# ======================================
# Artifact Registry IAM
# ======================================

# GitHub Actions Service Account permissions for API service repository
resource "google_artifact_registry_repository_iam_member" "api_service_writer" {
  project    = var.project_id
  location   = google_artifact_registry_repository.api_service.location
  repository = google_artifact_registry_repository.api_service.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# GitHub Actions Service Account permissions for Dashboard service repository
resource "google_artifact_registry_repository_iam_member" "dashboard_service_writer" {
  project    = var.project_id
  location   = google_artifact_registry_repository.dashboard_service.location
  repository = google_artifact_registry_repository.dashboard_service.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

