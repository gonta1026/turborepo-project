# IAM Configuration
# 環境に依存しない共通のIAM設定

# Google Groupベースでの権限管理
# Group: dev-my-third-developers@rakushite-inc.jp

# dev環境なので基本的にはなんでも触れるようにする。
locals {
  dev_roles = [
    # "roles/viewer",              # プロジェクト閲覧
    # "roles/storage.objectAdmin", # GCS管理
    # "roles/run.developer",       # Cloud Run開発
    # "roles/cloudsql.client",     # Cloud SQLクライアント
    # "roles/compute.networkUser", # VPC使用
    # "roles/logging.viewer",      # ログ閲覧
    # "roles/monitoring.viewer",   # モニタリング閲覧
    "roles/editor", # プロジェクト編集権限（開発環境では広範な権限を付与）

    "roles/iam.securityAdmin",               # Workload Identity Federation管理のために追加
    "roles/servicenetworking.networksAdmin", # Private Service Connection管理のために追加
  ]
}

# 開発チームグループにプロジェクトレベルの権限を付与
resource "google_project_iam_member" "dev_team_roles" {
  for_each = toset(local.dev_roles)

  project = var.project_id
  role    = each.value
  member  = "group:${var.dev_team_group}"
}

# ======================================
# GitHub Actions Service Account Roles
# ======================================

# GitHub Actions Service Accountに必要な権限を一括付与
resource "google_project_iam_member" "github_actions_deployer_roles" {
  for_each = toset([
    "roles/run.admin",                    # Cloud Runサービス管理権限（デプロイ・更新）
    "roles/storage.admin",                # GCSバケット管理権限（dashboard deploy用）
    "roles/artifactregistry.writer",      # Artifact Registryへの書き込み権限（コンテナイメージpush）
    "roles/iam.serviceAccountUser",       # サービスアカウント使用権限（Cloud Runでの権限借用）
    "roles/cloudsql.admin",               # Cloud SQL管理権限（migration job作成・実行用）
    "roles/secretmanager.secretAccessor", # Secret Manager読み取り権限（設定値取得）
    "roles/logging.viewer",               # ログ閲覧権限（デバッグ用）
    "roles/monitoring.viewer",            # モニタリング閲覧権限（ヘルスチェック用）
    "roles/compute.loadBalancerAdmin",    # CDNキャッシュ無効化権限（dashboard deploy用）
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"

  depends_on = [google_service_account.github_actions_deployer]
}


