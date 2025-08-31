# Terraform Backend Configuration for Dev Environment
# GCSを使用してTerraform状態ファイルを管理

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

  # これは作成したバケットを作成後に使用するためコメントアウト
  backend "gcs" {
    bucket = "my-fourth-dev-terraform-state"
    prefix = "dev"
  }
}

# Google Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# ======================================
# Note: Shared Module（Terraform State含む）
# ======================================
# Terraform State用GCSバケットはmain.tfのsharedモジュールで作成される
