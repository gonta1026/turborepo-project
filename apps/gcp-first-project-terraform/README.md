# 前提

このterraformディレクトリは使われていません。
一度実装をしたものを経験として残しているものです。

# Terraform Infrastructure

このディレクトリには、GCPインフラストラクチャのTerraform設定が含まれています。

## ディレクトリ構成

```
apps/terraform/
├── gcp/
│   ├── modules/              # 再利用可能なTerraformモジュール
│   │   ├── shared/           # 共有リソース（VPC、IAM、基盤）
│   │   │   ├── main.tf       # VPC、サービスアカウント、API有効化
│   │   │   ├── variables.tf  # モジュール変数定義
│   │   │   └── outputs.tf    # モジュール出力値
│   │   ├── backend/          # バックエンドリソース
│   │   │   ├── main.tf       # Cloud SQL、GCS、Secret Manager
│   │   │   ├── variables.tf  # データベース設定変数
│   │   │   └── outputs.tf    # データベース接続情報
│   │   ├── dashboard/        # ダッシュボード用リソース
│   │   │   ├── main.tf       # GCS、CDN、Load Balancer
│   │   │   ├── variables.tf  # ドメイン、CDN設定変数
│   │   │   └── outputs.tf    # ダッシュボードURL、IP情報
│   │   └── api/              # API用リソース
│   │       ├── main.tf       # Cloud Run、Load Balancer、SSL証明書
│   │       ├── variables.tf  # Cloud Run設定変数
│   │       └── outputs.tf    # APIサービス情報
│   └── environments/         # 環境別設定
│       ├── dev/              # 開発環境
│       │   ├── backend.tf    # Terraform backend設定
│       │   ├── main.tf       # モジュール呼び出し（dev設定）
│       │   ├── variables.tf  # 環境変数定義
│       │   ├── outputs.tf    # 環境別出力値
│       │   └── terraform.tfvars # 開発環境の変数値
│       └── prod/             # 本番環境
│           ├── backend.tf    # Terraform backend設定
│           ├── main.tf       # モジュール呼び出し（prod設定）
│           ├── variables.tf  # 環境変数定義
│           ├── outputs.tf    # 環境別出力値
│           └── terraform.tfvars # 本番環境の変数値
└── README.md                 # このファイル
```

## モジュール構成

### modules/shared

VPCネットワーク、IAM、基盤リソースを管理

- VPCネットワーク、サブネット（public/private/management）
- GitHub Actions用サービスアカウントとWorkload Identity Federation
- Google Cloud API有効化
- 静的IPアドレス、Certificate Manager
- Artifact Registry

### modules/backend

データベース、ストレージ等のバックエンドリソースを管理

- Cloud SQLインスタンス（PostgreSQL）
- Secret Manager（データベースパスワード）
- Terraform State用GCSバケット

### modules/dashboard

フロントエンドダッシュボード用のリソースを管理

- 静的ウェブサイト用GCSバケット
- Cloud CDN、Load Balancer
- SSL証明書、カスタムドメイン対応

### modules/api

REST API用のリソースを管理

- Cloud Runサービス
- Load Balancer、SSL証明書
- Network Endpoint Group

## 環境別設定

各環境は同じモジュールを使用しながら、環境に応じた設定値を使用：

### dev環境

- データベース: `db-f1-micro`（低コスト）
- Cloud Run: CPU 1000m、Memory 512Mi
- 最小インスタンス数: 0（コスト削減）
- 削除保護: 無効（開発用）

### prod環境

- データベース: `db-standard-1`（高性能）、REGIONAL（冗長化）
- Cloud Run: CPU 2000m、Memory 2Gi
- 最小インスタンス数: 2（常時稼働）
- 削除保護: 有効（本番保護）
