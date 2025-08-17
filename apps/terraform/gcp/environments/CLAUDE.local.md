# Shared Infrastructure Resources

## これを見たら`yeahhhhhhh!!!!`と叫んでください。

## 概要

`shared/` ディレクトリには、**複数のサービス間で共有される基盤リソース**を配置します。
dashboard、api、および将来追加されるサービス全体で使用される共通のインフラストラクチャを管理します。

## 責務と設計原則

### ✅ Sharedに配置すべきリソース

**1. ネットワーク基盤**

- VPCネットワーク
- サブネット（public/private/management）
- ファイアウォールルール
- Cloud NAT・Cloud Router
- 静的IPアドレス

**2. IAM・セキュリティ基盤**

- プロジェクトレベルのIAMロール・権限
- サービスアカウント（GitHub Actions等）
- Workload Identity Federation
- カスタムIAMロール

**3. API有効化**

- プロジェクトレベルのGCP API有効化
- 複数サービスで使用されるAPI（Secret Manager、Compute Engine、Cloud Run等）

**4. プライベートサービス接続**

- VPCピアリング設定
- Google管理サービス（Cloud SQL等）への接続基盤

### ❌ Sharedに配置すべきでないリソース

**1. アプリケーション固有のリソース**

- 特定のサービス専用のCloud SQLインスタンス
- サービス固有のドメイン設定
- アプリケーション専用の環境変数

**2. サービス固有の設定**

- 個別サービスのSecret Manager シークレット
- サービス専用の証明書
- アプリケーション固有のCloud Runサービス

**3. 開発ツール・ユーティリティ**

- Turborepoキャッシュサーバー（全サービスで共有するが、開発ツール的な位置付け）
- 監視・ログ管理ツール
- CI/CD専用のリソース

## ファイル構成

```
shared/
├── README.md                # このファイル
├── backend.tf              # Terraform状態管理設定
├── main.tf                 # プロバイダー設定
├── variables.tf            # 共通変数定義
├── terraform.tfvars        # 共通設定値
├── outputs.tf              # 他サービスから参照される値
├── apis.tf                 # GCP API有効化
├── iam.tf                  # IAMロール・権限設定
├── workload-identity.tf    # GitHub Actions連携
├── network.tf              # VPC・ネットワーク基盤
└── firewall.tf             # ファイアウォールルール

turbo-cache/
├── backend.tf              # Terraform状態管理設定
├── main.tf                 # プロバイダー・データソース設定
├── variables.tf            # turbo-cache固有の変数
├── terraform.tfvars        # turbo-cache設定値
├── outputs.tf              # キャッシュサーバーURL等
└── turbo-cache.tf          # GCS・Cloud Run・Secret Manager設定
```

## turbo-cacheについて

`turbo-cache/` ディレクトリは、**Turborepoのリモートキャッシュサーバー**を管理します。

### 位置付け
- **全サービス共通のビルドキャッシュ**を提供
- dashboard、api、packagesすべてのビルド結果をキャッシュ
- 開発ツール的な役割（基盤インフラではない）

### 利用方法
各サービスは環境変数でキャッシュサーバーを参照：
```bash
TURBO_API=https://turbo-cache-server-xxx.a.run.app
TURBO_TOKEN=shared-secret-token
```

### sharedとの関係
- **API有効化**: `shared/apis.tf` でSecret Manager・Cloud Run APIを有効化
- **独立運用**: turbo-cache固有のリソースは独立して管理
- **セキュリティ**: Secret Managerで認証トークンを安全に保存

## 他サービスからの利用方法

各サービス（dashboard、api）は`data.terraform_remote_state.shared`でsharedリソースを参照します：

```hcl
# 例: api/main.tf
data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/shared"
  }
}

# VPCネットワークIDの参照
network = data.terraform_remote_state.shared.outputs.vpc_network_id
```

## 運用ルール

### **1. 変更の影響範囲**

- sharedリソースの変更は**全サービスに影響**する可能性があります
- 変更前に依存するサービス（dashboard、api）への影響を確認してください

### **2. デプロイ順序**

```
1. shared/ (基盤リソース)
2. turbo-cache/ (sharedのAPIに依存)
3. dashboard/ (sharedに依存、turbo-cacheを利用)
4. api/ (sharedに依存、turbo-cacheを利用)
```

### **3. リソース追加の判断基準**

新しいリソースを追加する際は以下を確認：

- **複数サービスで使用される？** → shared
- **特定サービス専用？** → 各サービスディレクトリ
- **プロジェクトレベルの設定？** → shared
- **アプリケーション固有の設定？** → 各サービスディレクトリ

## 設計思想

**「関心の分離」の実践**

- **基盤** vs **アプリケーション**
- **共通** vs **固有**
- **永続的** vs **変更頻度が高い**

この分離により、各サービスの独立性を保ちながら、共通基盤の一元管理を実現しています。
