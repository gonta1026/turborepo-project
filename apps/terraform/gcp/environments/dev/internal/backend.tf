# Remote Backend Configuration for Dev Internal Environment
# このファイルはTerraformの状態ファイルをGCSに保存するための設定です

terraform {
  backend "gcs" {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/internal" # dev環境内のinternal専用プレフィックス
    # オプション設定
    # encryption_key = ""  # 顧客管理暗号化キーを使用する場合
    # impersonate_service_account = "" # サービスアカウントを使用する場合
  }
}
