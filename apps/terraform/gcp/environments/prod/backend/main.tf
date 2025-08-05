# GCS Backend Bucket for Production Environment Terraform State Management
# このファイルは本番環境のTerraformの状態ファイルを保存するGCSバケットを作成します

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

# Terraformの状態ファイル用GCSバケット
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  force_destroy = false # 誤った削除を防ぐ

  # バージョニングを有効化（状態ファイルの履歴管理）
  versioning {
    enabled = true
  }

  # パブリックアクセスを防ぐ
  public_access_prevention = "enforced"

  # uniform bucket-level access を有効化
  uniform_bucket_level_access = true

  # ライフサイクルルール（古いバージョンの削除）
  lifecycle_rule {
    condition {
      age = 100
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    purpose     = "terraform-state"
    managed_by  = "terraform"
    environment = "prod"
  }
}

resource "google_storage_bucket_iam_binding" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"

  members = [
    "projectOwner:${var.project_id}",
  ]
}
