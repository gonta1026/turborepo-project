# IAM設定ファイル - dev環境全体用（プロジェクトレベル）

# 開発チーム用グループに編集者権限を付与（dev環境全体）
resource "google_project_iam_binding" "dev_team_editor" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "group:${var.dev_team_group}",
  ]
}
