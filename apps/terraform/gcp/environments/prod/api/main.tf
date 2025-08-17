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
    bucket = "terraform-gcp-prod-468022-terraform-state"
    prefix = "prod/shared"
  }
}

# ======================================
# API Certificate Manager Resources
# ======================================
resource "google_certificate_manager_certificate" "api_cert" {
  name     = "api-cert"
  location = "global"

  managed {
    domains = [var.api_domain_name]
  }

  # Certificate Manager API有効化後に作成
  depends_on = [data.terraform_remote_state.shared]
}

# 共通Certificate MapにAPI用エントリーを追加
resource "google_certificate_manager_certificate_map_entry" "api_cert_map_entry" {
  name         = "api-cert-map-entry"
  map          = data.terraform_remote_state.shared.outputs.shared_certificate_map.name
  certificates = [google_certificate_manager_certificate.api_cert.id]
  hostname     = var.api_domain_name
}