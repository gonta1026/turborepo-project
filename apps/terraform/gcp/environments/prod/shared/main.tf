# Shared Infrastructure Configuration for Production Environment

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Terraform State管理設定
  backend "gcs" {
    bucket = "terraform-gcp-prod-468022-terraform-state"
    prefix = "shared"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

