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
# Cloud Storage for Static Website
# ======================================

# Cloud Storage bucket for static website hosting
resource "google_storage_bucket" "website_bucket" {
  name     = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-dashboard"
  location = var.region

  # 静的ウェブサイトホスティング用の設定
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # パブリックアクセス用の設定
  uniform_bucket_level_access = true

  # パブリックアクセス防止を無効化（静的サイト用）
  public_access_prevention = "inherited"

  labels = merge(
    {
      managed_by = "terraform"
      purpose    = "static-website"
    },
    var.labels
  )
}

# バケットをパブリックに設定
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
