# ======================================
# IAM設定 - prod環境用（プロジェクトレベル）
# ======================================

# 現在のプロジェクト情報を取得
data "google_project" "current" {}

# ======================================
# GitHub Actions用Service Account設定
# ======================================

# Service Account for GitHub Actions deployment
# Workload Identity Federationで使用するService Account
resource "google_service_account" "github_actions_deployer" {
  account_id   = "github-actions-prod"
  display_name = "GitHub Actions Production Deployer"
  description  = "Service account for GitHub Actions to deploy to production GCP services"
}

# ======================================
# Artifact Registry IAM
# ======================================

# GitHub ActionsサービスアカウントにArtifact Registry Writer権限を付与
# Docker ImageのpushとpullをするFull権限
resource "google_project_iam_member" "github_actions_artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# ======================================
# Cloud Run IAM
# ======================================

# GitHub ActionsサービスアカウントにCloud Run Developer権限を付与  
# Cloud Runサービスのデプロイと管理に必要
resource "google_project_iam_member" "github_actions_cloud_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# GitHub ActionsサービスアカウントにCloud Run Service Agent権限を付与
# Cloud Runサービスの実行に必要
resource "google_project_iam_member" "github_actions_cloud_run_service_agent" {
  project = var.project_id
  role    = "roles/run.serviceAgent"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# ======================================
# Cloud SQL IAM
# ======================================

# GitHub ActionsサービスアカウントにCloud SQL Client権限を付与
# Cloud SQL Proxyでの接続とインスタンス情報取得に必要
resource "google_project_iam_member" "github_actions_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# GitHub ActionsサービスアカウントにCloud SQL Instance User権限を付与
# Cloud SQLインスタンスへの接続権限
resource "google_project_iam_member" "github_actions_sql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# ======================================
# Storage & CDN IAM (for Dashboard deployment)
# ======================================

# GitHub ActionsサービスアカウントにStorage Admin権限を付与
# フロントエンドファイルのCloud Storageアップロードに必要
resource "google_project_iam_member" "github_actions_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# GitHub ActionsサービスアカウントにCompute Network Admin権限を付与
# CDNキャッシュの無効化に必要
resource "google_project_iam_member" "github_actions_compute_network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

# GitHub ActionsサービスアカウントにSecret Manager権限を付与
# マイグレーション時のSecret Manager アクセスに必要
resource "google_project_iam_member" "github_actions_secret_manager_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}