# 開発環境の管理方針

## ディレクトリ構造

```
dev/
├── backend.tf          # Backend設定とGCSバケット作成
├── main.tf            # メイン設定
├── variables.tf       # 変数定義
├── terraform.tfvars   # 変数値
└── README.md          # このファイル
```

## 初回セットアップ手順

### 1. 事前準備（手動）

1. GCPプロジェクト作成
2. billing_account設定
3. 認証設定（gcloud auth または サービスアカウント）

### 2. 初回実行

```bash
# terraform.tfvarsにproject_idを設定してから
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### 3. Backend有効化

```bash
# backend.tfのコメントを外す
# GCSバケットが作成されたら、backend設定を有効化
terraform init -migrate-state
```

### 4. 以降の運用

```bash
# 通常のTerraform運用
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## 管理方針

### 手動管理対象

- GCPプロジェクト作成
- billing_account設定
- 組織レベルのIAM設定

### Terraform管理対象

- Terraform State用GCSバケット
- VPCネットワーク設定
- コンピューティングリソース
- IAM設定（プロジェクトレベル）
- ストレージ設定
- モニタリング設定

## 理由

- **billing_account**: セキュリティ上の理由でコードに含めない
- **プロジェクト作成**: 初期設定の複雑性を回避
- **GCSバケット**: 同じTerraform設定内で作成・管理
- **シンプル設計**: Bootstrap不要でワンステップ実行
