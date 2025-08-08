terraform {
  required_version = ">= 1.12.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Remote state reference to shared resources
data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/shared"
  }
}