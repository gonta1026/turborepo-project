# プロジェクトIDの変数定義
variable "project_id" {
  description = "GCP Project ID for Production Environment"
  type        = string
}

# リージョンの変数定義
variable "region" {
  description = "GCP Region for Production Environment"
  type        = string
  default     = "asia-northeast1"
}

# ドメイン名の変数定義
variable "domain_name" {
  description = "Production Domain Name for Dashboard"
  type        = string
  default     = "dashboard.my-learn-iac-sample.site"
}

# バケット名の変数定義
variable "bucket_name" {
  description = "Production Cloud Storage Bucket Name for Dashboard"
  type        = string
  default     = "terraform-gcp-prod-468022-dashboard-frontend"
}

# CDNキャッシュTTL設定
variable "cdn_cache_ttl" {
  description = "CDN Cache TTL for Production Environment (in seconds)"
  type        = number
  default     = 3600 # 1時間
}

# GitHub Actions Workload Identity Federation設定
variable "github_repository" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string
  default     = "gonta1026/turborepo-project"
}
