# GCP Cloud Run & Cloud SQL プロダクションレディ構成 TODO

## 🛠️ 扱う技術スタック

### **クラウドプラットフォーム**

- **Google Cloud Platform (GCP)**
  - Cloud Run（コンテナベースサービス）
  - Cloud SQL（PostgreSQL）
  - VPC（Virtual Private Cloud）
  - Artifact Registry
  - Cloud Build
  - Secret Manager
  - Cloud KMS（暗号化）
  - Cloud NAT
  - Cloud DNS

### **Infrastructure as Code**

- **Terraform**
  - モジュール化設計
  - 状態管理（GCS Backend）
  - 複数環境管理
  - ポリシー検証

### **CI/CD & DevOps**

- **GitHub Actions**
  - Workload Identity Federation
  - OIDC認証
  - 段階的デプロイメント
  - セキュリティスキャン
- **Cloud Run Jobs**（マイグレーション用）

### **コンテナ・アプリケーション**

- **Docker**
  - マルチステージビルド
  - Distrolessイメージ
  - セキュリティ最適化
- **Go**（既存アプリケーション）
- **PostgreSQL**（データベース）

### **セキュリティ**

- **ネットワークセキュリティ**
  - VPCファイアウォール
  - プライベートサービス接続
  - Cloud SQL Proxy
- **IAM & 認証**
  - 最小権限原則
  - サービスアカウント
  - IAMデータベース認証
- **暗号化**
  - CMEK（Customer-Managed Encryption Keys）
  - SSL/TLS

### **監視・オブザーバビリティ**

- **Google Cloud Operations**
  - Cloud Logging
  - Cloud Monitoring
  - Cloud Trace
  - Cloud Profiler
- **SRE実践**
  - SLI/SLO設計
  - アラートポリシー

### **ネットワーキング**

- **VPC設計**
  - サブネット分離
  - プライベート接続
  - Cloud NAT
  - DNS管理

### **コンプライアンス・ガバナンス**

- **Security Command Center**
- **Container Analysis**
- **Binary Authorization**
- **監査ログ**

---

## 📋 概要

このプロジェクトでは、**既存のTurboRepoモノレポ構成にAPIサービスを追加**し、セキュアなプロダクション環境を構築します。現在、dashboardアプリケーション（React + Storage + CDN）が稼働している環境に、**Go API + PostgreSQL**の組み合わせでバックエンドサービスを追加します。

### **アーキテクチャ概要**

```
┌─────────────────────────────────────────────────────────┐
│                    TurboRepo構成                        │
├─────────────────────┬───────────────────────────────────┤
│ apps/dashboard      │ apps/api                          │
│ (既存・稼働中)      │ (新規・今回構築)                  │
│                     │                                   │
│ React Frontend      │ Go REST API                       │
│ ↓                   │ ↓                                 │
│ Cloud Storage       │ Cloud Run                         │
│ + Cloud CDN         │ (プライベートVPC内)               │
│                     │ ↓                                 │
│                     │ Cloud SQL PostgreSQL              │
│                     │ (プライベート接続のみ)            │
└─────────────────────┴───────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│            インフラ構成（Terraform管理）                 │
├─────────────────────────────────────────────────────────┤
│ apps/terraform/gcp/environments/dev/                    │
│ ├── backend/    (既存) GCS状態管理                      │
│ ├── shared/     (拡張) VPC・共通リソース                │
│ └── api/        (新規) Cloud Run・Cloud SQL             │
└─────────────────────────────────────────────────────────┘
```

### **セキュリティ重視の設計思想**

1. **ゼロトラスト原則**
   - Cloud SQLはプライベートIPのみでパブリックアクセス完全拒否
   - コンテナからのアクセスのみ許可
   - 最小権限でのIAM設計

2. **ネットワーク分離**
   - 専用VPCによる論理的分離
   - プライベートサブネット内でのデータベース配置
   - VPC Connectorによる安全なCloud Run ⇄ Cloud SQL通信

3. **多層防御**
   - ファイアウォールルールによる通信制限
   - Secret Managerでの認証情報管理
   - Container Analysisによる脆弱性スキャン

### **技術選択の理由**

**Cloud Run**選択理由:

- サーバーレス（運用負荷最小）
- VPC統合によるセキュア接続
- 自動スケーリング
- コンテナベースで既存Go APIとの親和性

**プライベートCloud SQL**選択理由:

- 完全なネットワーク分離
- エンタープライズセキュリティ
- 自動バックアップ・高可用性
- 運用の自動化

**GitHub Actions + Cloud Run Jobs**:

- CI/CDの完全自動化
- セキュアなマイグレーション実行
- monorepo対応の変更検知

### **段階的実装戦略**

**Phase 1**: ネットワーク基盤

- VPC・サブネット構築（shared）
- プライベートサービス接続

**Phase 2**: データベース基盤

- Cloud SQLプライベートインスタンス
- 接続テスト・検証

**Phase 3**: アプリケーション層

- Cloud Runサービス
- VPC統合・環境変数設定

**Phase 4**: CI/CD統合

- GitHub Actionsワークフロー
- マイグレーション自動化

### **学習目標**

このプロジェクトを通じて以下のスキルを習得します：

- **GCP実践**: セキュアなクラウド設計・構築
- **Terraform**: 大規模インフラのコード化・モジュール設計
- **セキュリティ**: ゼロトラスト・多層防御の実装
- **DevOps**: monorepo CI/CD・運用自動化
- **アーキテクチャ**: プロダクションレディな システム設計

---

## 1. アーキテクチャ設計・準備

### **既存プロジェクト拡張**

```
現在: dashboard（Storage + CDN）
追加: API（Cloud Run + Cloud SQL）
```

- [ ] **要件定義・設計**
  - [ ] API要件定義
    - [ ] パフォーマンス要件
    - [ ] セキュリティ要件（プライベート DB）
    - [ ] 可用性要件
  - [ ] アーキテクチャ設計
    - [ ] dashboard-api間通信設計
    - [ ] データフロー設計
    - [ ] セキュリティ境界設計

- [ ] **GCP環境確認・拡張**
  - [ ] 既存プロジェクト利用（dashboard用と同一）
  - [ ] 権限・ロール確認
  - [ ] 請求・予算設定確認

- [ ] **新規API用サービス有効化**
  - [ ] Cloud Run API
  - [ ] Cloud SQL API
  - [ ] Compute Engine API（VPC用）
  - [ ] Service Networking API（プライベート接続用）
  - [ ] 既存サービス確認
    - [ ] Artifact Registry API（既存確認）
    - [ ] Cloud Build API（既存確認）
    - [ ] Secret Manager API（新規）
    - [ ] Cloud KMS API（暗号化用・新規）

## 2. セキュアネットワーク基盤

- [ ] **VPCアーキテクチャ設計**
  - [ ] マルチリージョン対応VPC
  - [ ] サブネット設計（/24推奨）
    - [ ] パブリックサブネット（Load Balancer用）
    - [ ] プライベートサブネット（Cloud SQL用）
    - [ ] 管理サブネット（運用ツール用）
  - [ ] IPアドレス体系設計（RFC1918準拠）
- [ ] **ネットワークセキュリティ**
  - [ ] ファイアウォール階層設計
    - [ ] デフォルト拒否ポリシー
    - [ ] タグベースルール
    - [ ] 最小権限通信許可
  - [ ] Cloud NAT設定（プライベートサブネット用）
  - [ ] プライベートGoogleアクセス有効化
  - [ ] VPCフローログ有効化
- [ ] **DNS・ドメイン管理**
  - [ ] Cloud DNS設定
    - [ ] `my-learn-iac-sample.site` ドメイン設定
    - [ ] `dev.api.my-learn-iac-sample.site` サブドメイン作成
  - [ ] プライベートDNSゾーン
  - [ ] SSL証明書管理戦略
    - [ ] **Certificate Manager**（既存技術と統一）
    - [ ] Google-managed SSL証明書
    - [ ] Certificate Map設定

**🔍 動作確認ポイント1: ネットワーク基盤**

- [ ] VPC作成確認: `gcloud compute networks describe`
- [ ] サブネット確認: `gcloud compute networks subnets list`
- [ ] DNS設定確認: `nslookup dev.api.my-learn-iac-sample.site`

## 3. データベース層（エンタープライズ構成）

- [ ] **Cloud SQL高可用性設計**
  - [ ] リージョナルインスタンス設計
  - [ ] 自動バックアップ・ポイントインタイムリカバリ
  - [ ] 読み取りレプリカ設計（パフォーマンス用）
  - [ ] メンテナンスウィンドウ設定
- [ ] **プライベート接続**
  - [ ] プライベートサービス接続
  - [ ] VPCピアリング設定
  - [ ] 専用IP範囲割り当て
  - [ ] パブリックIP完全無効化
- [ ] **セキュリティ・暗号化**
  - [ ] 保存時暗号化（CMEK使用）
  - [ ] 転送中暗号化（SSL/TLS強制）
  - [ ] データベースユーザー管理
  - [ ] IAMデータベース認証
- [ ] **監視・アラート**
  - [ ] Cloud SQLインサイト有効化
  - [ ] パフォーマンス監視
  - [ ] 接続数・クエリ監視

**🔍 動作確認ポイント2: データベース**

- [ ] Cloud SQLインスタンス確認: `gcloud sql instances describe`
- [ ] プライベートIP接続確認: `gcloud sql instances describe --format="value(ipAddresses[0].ipAddress)"`
- [ ] データベース接続テスト（Cloud SQL Proxy経由）:
  ```bash
  # Cloud SQL Proxyで接続テスト
  cloud-sql-proxy --instances=PROJECT:REGION:INSTANCE=tcp:5432 &
  psql -h 127.0.0.1 -p 5432 -U api_user -d api_db
  ```

## 4. コンテナ化・セキュリティ強化

- [ ] **マルチステージDockerfile**
  - [ ] distrolessベースイメージ使用
  - [ ] 非rootユーザー実行
  - [ ] 最小権限コンテナ設計
  - [ ] セキュリティスキャン対応
- [ ] **イメージ管理**
  - [ ] Artifact Registry設定
  - [ ] イメージタグ戦略（semantic versioning）
  - [ ] Container Analysis有効化
  - [ ] Binary Authorization設定
- [ ] **アプリケーション設定**
  - [ ] 12-Factor App準拠
  - [ ] Secret Manager連携
  - [ ] 構造化ログ実装
  - [ ] ヘルスチェックエンドポイント

## 5. Infrastructure as Code（Terraform）

### **既存構成の活用**

```
apps/terraform/gcp/environments/dev/
├── backend/     (既存) - Terraform状態管理
├── shared/      (拡張) - VPC・共通リソース
└── api/         (新規) - API専用リソース
```

- [ ] **shared ディレクトリ（共通リソース）**

  ```
  shared/ (dashboard・api・将来のサービスで共用)
  ├── 既存: Workload Identity Federation
  ├── 追加: VPC・ネットワーク基盤
  ├── 追加: Certificate Manager統合
  └── 追加: 共通セキュリティリソース
  ```

  - [ ] **ネットワーク基盤（新規追加）**
    - [ ] メインVPC作成
      - [ ] `main-vpc`（dashboard・api共通）
      - [ ] パブリックサブネット（Load Balancer用）
      - [ ] プライベートサブネット（Cloud SQL用）
    - [ ] Cloud NATゲートウェイ
    - [ ] ファイアウォール基盤ルール
  - [ ] **Certificate Manager統合（既存拡張）**
    - [ ] 既存Certificate Map拡張
      - [ ] `my-learn-iac-sample.site`（dashboard用・既存）
      - [ ] `dev.api.my-learn-iac-sample.site`（API用・追加）
    - [ ] SSL証明書の一元管理
    - [ ] DNS設定統合
  - [ ] **共通セキュリティリソース（新規追加）**
    - [ ] KMS暗号化キー
    - [ ] Secret Manager設定
    - [ ] 共通IAMロール
  - [ ] **プライベートサービス接続（新規追加）**
    - [ ] VPCピアリング設定
    - [ ] プライベートIP範囲予約
    - [ ] VPC Connector作成
  - [ ] **Workload Identity Federation（既存拡張）**
    - [ ] API用権限追加
    - [ ] monorepo対応の条件設定

- [ ] **api ディレクトリ（API専用リソース）**
  - [ ] ディレクトリ構造作成
    ```
    api/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── modules/
        ├── cloud-sql/
        ├── cloud-run/
        └── monitoring/
    ```
  - [ ] Cloud SQLリソース
    - [ ] PostgreSQLインスタンス（プライベート）
    - [ ] データベース・ユーザー作成
    - [ ] バックアップ設定
  - [ ] Cloud Runサービス
    - [ ] サービス設定
    - [ ] VPC統合（shared/VPCを利用）
    - [ ] 環境変数・シークレット（shared/Secret Manager利用）
    - [ ] IAM権限設定
    - [ ] カスタムドメイン設定
      - [ ] `dev.api.my-learn-iac-sample.site`
      - [ ] **shared/Certificate Manager活用**
        - [ ] 既存Certificate Map Entry追加のみ
        - [ ] dashboard用と同一管理
      - [ ] Cloud Load Balancer設定
      - [ ] Target HTTPS Proxy設定
  - [ ] 監視・ログ設定
    - [ ] Cloud Loggingシンク
    - [ ] アラートポリシー
    - [ ] ダッシュボード

**🔍 動作確認ポイント3: API デプロイ**

- [ ] Cloud Runサービス確認: `gcloud run services describe api-service`
- [ ] デフォルトURL確認: `gcloud run services describe api-service --format="value(status.url)"`
- [ ] カスタムドメインアクセス確認:

  ```bash
  # ヘルスチェック
  curl -s https://dev.api.my-learn-iac-sample.site/health
  # APIレスポンス確認
  curl -s https://dev.api.my-learn-iac-sample.site/api/v1/status
  ```

- [ ] **状態管理・依存関係**
  - [ ] backend設定の再利用
    - [ ] 既存GCSバケット利用（dashboard/backend）
    - [ ] api用状態ファイル分離
    - [ ] 状態ロック設定
  - [ ] モジュール間依存管理
    - [ ] **shared → api の依存関係**
      - [ ] VPC ID参照
      - [ ] サブネット ID参照
      - [ ] Certificate Map参照
      - [ ] Secret Manager参照
    - [ ] terraform_remote_state活用
    - [ ] outputs/inputs設計

**🔍 動作確認ポイント2.5: shared拡張確認**

- [ ] shared拡張リソース確認:

  ```bash
  # 共通VPC確認
  gcloud compute networks describe main-vpc

  # Certificate Map Entry確認（dashboard + API）
  gcloud certificate-manager maps entries list --map=dashboard-cert-map

  # shared状態確認
  terraform -chdir=apps/terraform/gcp/environments/dev/shared output
  ```

- [ ] **環境変数・設定ファイル**
  - [ ] terraform.tfvars設計
    - [ ] 環境固有値（dev/prod）
    - [ ] リソース名規則
    - [ ] ネットワーク設定
  - [ ] 変数検証
    - [ ] validation blocks
    - [ ] type constraints
    - [ ] sensitive値管理

## 6. CI/CD パイプライン（GitHub Actions）

- [ ] **ワークフロー設計（TurboRepo統合）**
  - [ ] monorepo対応ワークフロー
  - [ ] apps/api変更検知
  - [ ] apps/terraform変更検知
  - [ ] 段階的デプロイ戦略

- [ ] **Terraformデプロイフロー（共通リソース戦略）**
  - [ ] shared リソース拡張デプロイ
    ```yaml
    1. shared/terraform plan（既存リソース影響確認）
    2. shared/terraform apply（VPC・Certificate Manager拡張）
    3. outputs確認（api用ID・参照値）
    4. dashboard影響確認（継続稼働確認）
    ```
  - [ ] api リソースデプロイ
    ```yaml
    1. api/terraform plan（shared依存確認）
    2. terraform_remote_state でshared参照
    3. api/terraform apply（Cloud SQL・Cloud Run）
    4. shared統合確認・接続性テスト
    ```

- [ ] **アプリケーションデプロイフロー**

  ```yaml
  # .github/workflows/deploy-api.yml
  1. apps/api 変更検知
  2. Go テスト実行
  3. Dockerイメージビルド
  4. Artifact Registryプッシュ
  5. shared Terraformデプロイ（必要時）
  6. api Terraformデプロイ
  7. Cloud Run Jobs（マイグレーション）
  8. Cloud Runサービス更新
  9. ヘルスチェック・スモークテスト
  ```

- [ ] **セキュリティ・認証**
  - [ ] Workload Identity Federation設定
    - [ ] 既存設定の拡張
    - [ ] api用権限追加
  - [ ] GitHub Secrets管理
    - [ ] PROJECT_ID
    - [ ] WORKLOAD_IDENTITY_PROVIDER
    - [ ] API固有のシークレット

- [ ] **品質ゲート・検証**
  - [ ] Terraformバリデーション
    - [ ] terraform fmt
    - [ ] terraform validate
    - [ ] tfsec（セキュリティスキャン）
  - [ ] アプリケーション検証
    - [ ] Go lint・test
    - [ ] Dockerfile security scan
    - [ ] 依存関係脆弱性チェック

## 7. 運用・マイグレーション戦略

- [ ] **データベースマイグレーション**
  - [ ] Cloud Run Jobs設定
    - [ ] マイグレーション専用コンテナ
    - [ ] 同一VPC接続設定
    - [ ] 実行権限最小化
  - [ ] GitHub Actionsからの実行
  - [ ] ロールバック戦略
  - [ ] マイグレーション履歴管理
- [ ] **運用ツール**
  - [ ] 緊急時アクセス手順
  - [ ] Cloud Shell + Cloud SQL Proxy
  - [ ] データベース管理ツール
  - [ ] バックアップ・リストア手順

## 8. 監視・オブザーバビリティ

- [ ] **ログ管理**
  - [ ] 構造化ログ（JSON）
  - [ ] Cloud Loggingシンク設定
  - [ ] ログ保持ポリシー
  - [ ] セキュリティログ監査
- [ ] **メトリクス・アラート**
  - [ ] SLI/SLO設定
  - [ ] カスタムメトリクス
  - [ ] アラートポリシー
  - [ ] エスカレーション設定
- [ ] **分散トレーシング**
  - [ ] Cloud Trace統合
  - [ ] APM設定
  - [ ] パフォーマンス分析

## 9. セキュリティ・コンプライアンス

- [ ] **セキュリティ強化**
  - [ ] Security Command Center設定
  - [ ] Web Security Scanner
  - [ ] Event Threat Detection
  - [ ] Cloud Asset Inventory
- [ ] **コンプライアンス**
  - [ ] 監査ログ設定
  - [ ] アクセス制御レビュー
  - [ ] 脆弱性管理プロセス
  - [ ] インシデント対応手順

## 10. 本番デプロイ・検証

- [ ] **段階的デプロイ**
  - [ ] dev環境での完全テスト
  - [ ] staging環境での統合テスト
  - [ ] prod環境でのカナリアデプロイ
- [ ] **本番検証**
  - [ ] エンドツーエンドテスト
  - [ ] パフォーマンステスト
  - [ ] セキュリティ検証
  - [ ] 災害復旧テスト

**🔍 動作確認ポイント4: 本番確認**

- [ ] 全体システム動作確認:

  ```bash
  # API疎通確認
  curl -i https://dev.api.my-learn-iac-sample.site/api/v1/health

  # データベース接続確認（APIエンドポイント経由）
  curl -X POST https://dev.api.my-learn-iac-sample.site/api/v1/users \
    -H "Content-Type: application/json" \
    -d '{"name":"test","email":"test@example.com"}'

  # レスポンス確認
  curl https://dev.api.my-learn-iac-sample.site/api/v1/users
  ```

- [ ] SSL証明書確認:

  ```bash
  # Certificate Manager証明書確認
  gcloud certificate-manager certificates describe api-cert --location=global

  # Certificate Map確認
  gcloud certificate-manager maps describe api-cert-map

  # 証明書詳細確認（ブラウザレベル）
  openssl s_client -connect dev.api.my-learn-iac-sample.site:443 -servername dev.api.my-learn-iac-sample.site
  ```

- [ ] パフォーマンス確認:
  ```bash
  # レスポンス時間測定
  curl -w "@curl-format.txt" -o /dev/null -s https://dev.api.my-learn-iac-sample.site/api/v1/health
  ```
- [ ] **運用移行**
  - [ ] 監視ダッシュボード構築
  - [ ] 運用手順書作成
  - [ ] オンコール体制構築
  - [ ] SLA設定

## 11. 学習・スキル習得

- [ ] **TurboRepo・Monorepo理解**
  - [ ] apps間の依存関係理解
  - [ ] 変更検知・ビルド戦略
  - [ ] 既存プロジェクト拡張パターン

- [ ] **Terraform実践**
  - [ ] モジュール設計パターン
  - [ ] 状態管理ベストプラクティス
  - [ ] shared/api間の依存関係管理
  - [ ] terraform_remote_state活用

- [ ] **GCPアーキテクチャ理解**
  - [ ] VPCネットワーキング深掘り
  - [ ] プライベートサービス接続
  - [ ] Cloud Run VPC統合理解
  - [ ] Cloud SQL接続パターン

- [ ] **CI/CD実践（GitHub Actions）**
  - [ ] monorepo対応ワークフロー
  - [ ] Workload Identity Federation
  - [ ] 段階的デプロイ戦略
  - [ ] Cloud Run Jobs活用

- [ ] **セキュリティベストプラクティス**
  - [ ] ゼロトラストアーキテクチャ
  - [ ] 最小権限原則実装
  - [ ] プライベートネットワーク設計
  - [ ] シークレット管理戦略

- [ ] **運用・保守スキル**
  - [ ] Cloud SQL運用管理
  - [ ] Cloud Runスケーリング調整
  - [ ] 監視・アラート設定
  - [ ] トラブルシューティング手法
