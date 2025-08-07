# Workload Identity Federation Configuration for GitHub Actions
# Dev環境全体で共有するGitHub Actions用のWorkload Identity Federation設定

# ======================================
# Workload Identity Federation Configuration - Step 2: Pool
# ======================================

# terraform import google_iam_workload_identity_pool.github_actions_pool projects/terraform-gcp-466623/locations/global/workloadIdentityPools/github-actions-pool
# Workload Identity Pool
# GitHub ActionsとGCPサービスアカウント間の信頼関係を管理するプールを作成
# 外部IDプロバイダー（GitHub）からのトークンを検証し、GCPリソースへのアクセスを制御
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# ======================================
# Workload Identity Federation Configuration - Step 3: Provider
# ======================================

# Workload Identity Provider
# GitHub ActionsのOIDCトークンを検証するプロバイダーを設定
# 特定のGitHubリポジトリからのリクエストのみを許可してセキュリティを強化
resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC identity pool provider for GitHub Actions"

  # プロバイダのマッピングを構成する（ステップ3）
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # 特定のリポジトリからのアクセスのみを許可
  attribute_condition = "assertion.repository == '${var.github_repository}'"

  # ID プロバイダを接続する（ステップ2）
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
