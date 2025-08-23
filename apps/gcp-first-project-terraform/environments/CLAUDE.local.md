# Terraform Infrastructure Guide

## 概要

このTerraformプロジェクトは、環境とモジュールベースの構成で整理されています。
各環境（dev/prod）で共通のモジュールを利用し、設定値のみを環境固有にしています。

## ディレクトリ構成

```
apps/terraform/
├── environments/           # 環境固有の設定
│   ├── dev/               # 開発環境
│   │   ├── backend.tf     # Terraform状態管理設定
│   │   ├── main.tf        # メインの環境設定
│   │   ├── outputs.tf     # 環境のアウトプット
│   │   ├── terraform.tfvars  # 開発環境固有の設定値
│   │   └── variables.tf   # 変数定義
│   └── prod/              # 本番環境
│       ├── backend.tf     # Terraform状態管理設定
│       ├── main.tf        # メインの環境設定
│       ├── outputs.tf     # 環境のアウトプット
│       ├── terraform.tfvars  # 本番環境固有の設定値
│       └── variables.tf   # 変数定義
└── modules/               # 再利用可能なモジュール
    ├── api/               # APIサーバーリソース
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── dashboard/         # ダッシュボードアプリリソース
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── shared/            # 共通基盤リソース
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## モジュール責務

### **shared モジュール**

複数のサービス間で共有される基盤リソースを管理：

- VPCネットワーク、サブネット
- ファイアウォールルール
- プロジェクトレベルのIAMロール・権限
- GCP API有効化
- Workload Identity Federation
- 静的IPアドレス
- Terraform状態管理用GCSバケット

### **api モジュール**

Go APIサーバーに関連するリソース：

- Cloud Runサービス
- Cloud SQLインスタンス（PostgreSQL）
- データベースユーザーとSecret Manager
- Load Balancer、SSL証明書
- データベースマイグレーション関連設定

### **dashboard モジュール**

React TypeScript frontendアプリに関連するリソース：

- Cloud Runサービス
- 静的ファイルホスティング（必要に応じて）
- フロントエンド固有の設定

## 環境固有設定

各環境（dev/prod）では、モジュールを呼び出して環境固有の設定値を渡します：

```hcl
# environments/dev/main.tf 例
module "shared" {
  source = "../../modules/shared"

  project_id    = var.project_id
  environment   = "dev"
  region        = var.region
}

module "api" {
  source = "../../modules/api"

  project_id     = var.project_id
  environment    = "dev"
  vpc_network    = module.shared.vpc_network
  database_tier  = "db-f1-micro"  # dev環境用の小さなインスタンス
}
```

## デプロイ順序

1. **shared**: 基盤リソース（VPC、IAM、状態管理バケット等）
2. **api**: APIサーバー（sharedリソースに依存、データベース含む）
3. **dashboard**: フロントエンドアプリ（sharedに依存）

## 状態管理

各環境の状態は分離してGCSに保存：

- dev環境: `gs://terraform-state-bucket/dev/`
- prod環境: `gs://terraform-state-bucket/prod/`

## 運用ルール

### **1. 環境の分離**

- dev環境とprod環境の状態は完全に分離
- 設定値は各環境の`terraform.tfvars`で管理

### **2. モジュール変更の影響**

- モジュールの変更は全環境に影響する可能性があります
- 変更前にdev環境で十分にテストしてください

### **3. リソース追加の判断**

- **複数サービス・環境で使用** → shared モジュール
- **APIサーバー関連（データベース含む）** → api モジュール
- **フロントエンド関連** → dashboard モジュール
- **環境固有の設定** → environments配下のterraform.tfvars

## 設計思想

**環境とコードの分離**

- モジュール = 再利用可能なインフラコード
- 環境 = 環境固有の設定値とモジュール呼び出し

この構成により、コードの再利用性を保ちながら環境間の設定差異を明確に管理できます。
