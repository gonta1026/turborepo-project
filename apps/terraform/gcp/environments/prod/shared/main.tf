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

# ======================================
# Enable Required APIs
# ======================================

# Enable Compute Engine API
# ロードバランサー、グローバルIPアドレス、URLマップなどの作成に必要なCompute Engine APIを有効化
# 静的IPアドレスの取得やHTTPS/HTTPプロキシの作成に使用される
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Certificate Manager API
# Google Certificate Managerを使用してSSL証明書を自動管理するためのAPIを有効化
# これにより、ドメインの証明書を自動取得・更新できるようになる
resource "google_project_service" "certificate_manager_api" {
  service = "certificatemanager.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable IAM Service Account Credentials API
# Workload Identity Federationを使用するために必要なAPIを有効化
# GitHub ActionsがService Accountの一時的な認証情報を取得するために使用される
resource "google_project_service" "iam_credentials_api" {
  service = "iamcredentials.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}
