# プロジェクトIDの変数定義
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# リージョンの変数定義
variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
} 
