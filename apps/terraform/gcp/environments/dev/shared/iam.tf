# IAM設定ファイル - dev環境全体用（プロジェクトレベル）

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
# Project Level IAM Bindings
# ======================================

# 開発チーム用グループに編集者権限を付与（dev環境全体）
resource "google_project_iam_binding" "dev_team_editor" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "group:${var.dev_team_group}",
  ]
}
