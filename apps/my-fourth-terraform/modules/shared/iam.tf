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
    "roles/editor",                # プロジェクト編集権限（開発環境では広範な権限を付与）
    "roles/iam.securityAdmin"      # Workload Identity Federation管理のために追加
  ]
}

# 開発チームグループにプロジェクトレベルの権限を付与
resource "google_project_iam_member" "dev_team_roles" {
  for_each = toset(local.dev_roles)

  project = var.project_id
  role    = each.value
  member  = "group:${var.dev_team_group}"
}

