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

# GitHub Actions Configuration
variable "github_repository" {
  description = "GitHub repository for Workload Identity Federation (format: owner/repo)"
  type        = string
} 
