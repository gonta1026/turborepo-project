# IAM設定ファイル - dev環境全体用（プロジェクトレベル）

# ======================================
# Data Sources
# ======================================

# 現在のプロジェクト情報を取得
data "google_project" "current" {}

# ======================================
# Shared IAM Custom Roles
# ======================================

# CDNキャッシュの無効化に必要な最小限の権限を定義するカスタムロール
resource "google_project_iam_custom_role" "cache_invalidator" {
  role_id     = "cacheInvalidator"
  title       = "Cache Invalidator"
  description = "Custom role for CDN cache invalidation with minimal permissions"
  permissions = [
    "compute.urlMaps.invalidateCache",
    "compute.urlMaps.get"
  ]
}

# ======================================
# Shared Service Accounts
# ======================================

# Service Account for GitHub Actions deployment across services
resource "google_service_account" "github_actions_deployer" {
  account_id   = "github-actions-dashboard"
  display_name = "GitHub Actions Dashboard Deployer"
  description  = "Service account for GitHub Actions to deploy to GCP services"
}

# Service Account Key for GitHub Actions (学習用途)
# NOTE: サービスアカウントキーの使用は非推奨です
# セキュリティ向上のため、Workload Identity Federationの使用を強く推奨をするが「組織」の設定が必要なため、学習用の目的でサービスアカウントを利用する
resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions_deployer.name
  key_algorithm      = "KEY_ALG_RSA_2048"
}

# ======================================
# Project Level IAM Bindings
# ======================================

# 開発チーム用グループに編集者権限を付与（dev環境全体）
resource "google_project_iam_binding" "dev_team_editor" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "group:${var.dev_team_group}",
    # Google APIs Service Agent - VPCコネクター作成に必要
    "serviceAccount:${data.google_project.current.number}@cloudservices.gserviceaccount.com",
  ]
}

# ======================================
# Cloud SQL IAM Access
# ======================================

# Cloud SQL Client Role for developers
# Cloud SQL Proxyでの接続に必要な権限
resource "google_project_iam_member" "dev_team_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "group:${var.dev_team_group}"
}

# Cloud SQL Instance User Role for developers
# Cloud SQLインスタンスへの接続権限
resource "google_project_iam_member" "dev_team_sql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "group:${var.dev_team_group}"
}

# ======================================
# GitHub Actions Service Account IAM
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
