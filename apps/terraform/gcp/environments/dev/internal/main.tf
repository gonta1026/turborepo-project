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

module "master" {
  source     = "../../../modules/setup"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  # 将来的なCloud Storage/CDN用の設定
  bucket_name = var.bucket_name
  domain_name = var.domain_name
  labels      = var.labels
}
