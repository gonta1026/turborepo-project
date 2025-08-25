# ======================================
# Shared Resources Module
# ======================================
# VPC、IAM、基盤リソースを管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project    = var.project_id
    managed_by = "terraform"
  })

  # network_name = "${var.project_id}-vpc"

  # public_subnet_cidr     = "10.0.1.0/24"
  # private_subnet_cidr    = "10.0.2.0/24"
  # management_subnet_cidr = "10.0.3.0/24"
  # vpc_connector_cidr     = "10.8.0.0/28"
}

# ======================================
# GCPプロジェクト参照
# ======================================
# Note: プロジェクトは手動で作成済み

# ======================================
# API有効化
# ======================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # VM、ネットワーク、ロードバランサー
    "iam.googleapis.com",                  # 権限管理
    "iamcredentials.googleapis.com",       # サービスアカウント認証
    "storage.googleapis.com",              # GCSバケット管理
    "storage-api.googleapis.com",          # GCSデータアクセス
    "cloudresourcemanager.googleapis.com", # プロジェクト、フォルダ管理
    "serviceusage.googleapis.com",         # API有効化・無効化管理
    "cloudapis.googleapis.com",            # Google Cloud API基盤サービス
    "monitoring.googleapis.com",           # Cloud Monitoring（メトリクス）
    "logging.googleapis.com",              # Cloud Logging（ログ管理）
    "cloudidentity.googleapis.com",        # Googleグループ、ユーザー管理
    "artifactregistry.googleapis.com",     # Artifact Registry
    "run.googleapis.com",                  # Cloud Run
    "cloudbuild.googleapis.com",           # Cloud Build
    "servicenetworking.googleapis.com",    # Provides automatic management of network configurations
    "sql-component.googleapis.com",        # Provides automatic management of network configurations
    "sqladmin.googleapis.com",             # Cloud SQL
    "cloudkms.googleapis.com",             # Cloud KMS
    "secretmanager.googleapis.com",        # Secret Manager
    "certificatemanager.googleapis.com",   # Certificate Manager
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

}


# ======================================
# サービスアカウント
# ======================================
resource "google_service_account" "github_actions_deployer" {
  project      = var.project_id
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer"
  description  = "Service account for GitHub Actions deployment"

  depends_on = [google_project_service.required_apis]
}

# ======================================
# Terraform State用GCSバケット
# ======================================
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  storage_class = "STANDARD"
  project       = var.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # 古いバージョンの自動削除
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
      with_state         = "ARCHIVED"
    }
  }

  # 非現行バージョンの自動アーカイブ
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age        = 30
      with_state = "LIVE"
    }
  }

  labels = merge(local.common_labels, {
    purpose = "terraform-state"
  })

  depends_on = [google_project_service.required_apis]
}
