# プロジェクトIDの変数定義
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# リージョンの変数定義（デフォルト値を設定）
variable "region" {
  description = "GCP Region for resources"
  type        = string
  default     = "asia-northeast1" # 東京リージョンをデフォルトに設定
}
