# ======================================
# TERRAFORM VARIABLES - Prod Environment
# 全サービス共通の変数定義ファイル
# ======================================

# ======================================
# プロジェクト基本設定
# ======================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  # default     = {}
}

# ======================================
# Shared Resources - IAM & GitHub Actions設定
# ======================================

variable "dev_team_group" {
  description = "Production team Google group email (prod-rakushite-developers group)"
  type        = string
}
