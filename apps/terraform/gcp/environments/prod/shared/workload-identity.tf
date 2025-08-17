# Workload Identity Federation Configuration for GitHub Actions
# Production環境全体で共有するGitHub Actions用のWorkload Identity Federation設定

# ======================================
# Workload Identity Federation Configuration - Step 1: Pool
# ======================================

# Workload Identity Pool
# GitHub ActionsとGCPサービスアカウント間の信頼関係を管理するプールを作成
# 外部IDプロバイダー（GitHub）からのトークンを検証し、GCPリソースへのアクセスを制御
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  workload_identity_pool_id = "github-actions-pool-prod"
  display_name              = "GitHub Actions Pool Prod"
  description               = "Workload Identity Pool for GitHub Actions in Production"
}

# ======================================
# Workload Identity Federation Configuration - Step 2: Provider
# ======================================

# Workload Identity Provider
# GitHub ActionsのOIDCトークンを検証するプロバイダーを設定
# 特定のGitHubリポジトリからのリクエストのみを許可してセキュリティを強化
resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider-prod"
  display_name                       = "GitHub Actions Provider Prod"
  description                        = "OIDC identity pool provider for GitHub Actions in Production"

  # プロバイダのマッピングを構成する
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # 特定のリポジトリからのアクセスのみを許可
  attribute_condition = "assertion.repository == '${var.github_repository}'"

  # OIDCプロバイダー設定
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ======================================
# Service Account Impersonation
# ======================================

# Workload Identity FederationがGitHub ActionsサービスアカウントをImpersonateする権限
# GitHub ActionsがProduction環境のサービスアカウントとして実行できるようにする
resource "google_service_account_iam_member" "github_actions_workload_identity_binding" {
  service_account_id = google_service_account.github_actions_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_pool.name}/attribute.repository/${var.github_repository}"
}