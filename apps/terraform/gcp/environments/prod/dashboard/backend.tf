# Production Dashboard Terraform State Configuration
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # 本番環境用のTerraform State管理設定
  backend "gcs" {
    bucket = "terraform-gcp-prod-468022-terraform-state" # Step 1で作成したバケット名
    prefix = "dashboard"                                 # このモジュール用のプレフィックス
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
