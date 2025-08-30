## terraformの構成について

- rakushite-inc.jp （google workspaseで作成をされた組織）
  - my-fourth-dev（dev環境）
  - my-fourth-prod （本番）
  - my-fourth-quota （請求の設定、別リポジトリ）

このリポジトリで操作をするのは、 my-fourth-dev と my-fourth-prod になります。

## 初期手順

1. owner権限を持つ開発者にグループへの招待を依頼してください。
2. 招待をしてもらうとgcpのコンソールにログインが可能になるはずです。
3. gcloud コマンドをinstallしてください。[ドキュメントはこちら](https://cloud.google.com/sdk/docs/install?hl=ja)

```bash
# 開発環境用の設定を作成
gcloud config configurations create [ex: my-fourth-dev-name]
gcloud config set account [groupに招待をしてもらったemail]
gcloud config set project my-fourth-dev

# 本番環境用の設定を作成（招待をされている場合）
gcloud config configurations create [ex: my-fourth-prod-name]
gcloud config set account [groupに招待をしてもらったemail]
gcloud config set project my-fourth-prod

# 登録をした特定の構成をアクティブにする。アクティブにした構成でgcloudでアクセスをされる
gcloud config configurations activate my-fourth-dev-katano
# ADCの仕組みで対象のアカウントでログインをする。
gcloud auth application-default login

```

現状のアクティブアカウントを確認

```bash
# 現在のプロジェクトID
gcloud config get-value project
```

```bash
# 現在の構成の一覧
gcloud config configurations list
```

## インフラ構成図

```mermaid
graph TB
    subgraph "Internet"
        Users[Users]
        DNS[ムームードメイン<br/>dev.api.domain.com]
    end

    subgraph "GCP Project (my-fourth-dev)"
        subgraph "Global Resources"
            LB[Global Load Balancer]
            SSL[SSL Certificate<br/>Certificate Manager]
            StaticIP[Static IP Address]
        end

        subgraph "Google Serverless Platform"
            CloudRun[Cloud Run<br/>API Server<br/>Go Gin]
        end

        subgraph "VPC Network (main-vpc)"
            subgraph "Public Subnet (10.0.1.0/24)"
                NATGW[Cloud NAT Gateway]
                Router[Cloud Router<br/>BGP ASN: 64514]
            end

            subgraph "Private Subnet (10.0.2.0/24)"
                CloudSQL[Cloud SQL<br/>PostgreSQL<br/>Private IP]
            end

            subgraph "VPC Connector Subnet (10.8.0.0/28)"
                VPCConn[VPC Access Connector<br/>Cloud Run → VPC]
            end
        end

        subgraph "Storage & Registry"
            AR[Artifact Registry<br/>Container Images]
            GCS[GCS Bucket<br/>Terraform State]
            SM[Secret Manager<br/>DB Credentials]
        end

        subgraph "IAM & Security"
            SA1[GitHub Actions SA<br/>Deploy & Build]
            SA2[Cloud Run SA<br/>Runtime Access]
            WIF[Workload Identity<br/>Federation]
        end

        subgraph "Monitoring & Logging"
            FW[Firewall Rules<br/>HTTP/HTTPS/Health]
            MON[Cloud Monitoring]
            LOG[Cloud Logging]
        end
    end

    subgraph "CI/CD"
        GH[GitHub Actions<br/>Build & Deploy]
        DEV[Developer]
    end

    %% User Flow (Inbound)
    Users -->|HTTPS Request| DNS
    DNS -->|A Record| StaticIP
    StaticIP --> LB
    LB -->|SSL Termination| SSL
    LB --> CloudRun

    %% Cloud Run Outbound Connections
    CloudRun -.->|VPC Egress| VPCConn
    VPCConn --> CloudSQL
    CloudRun --> SM
    CloudRun -.->|External API Calls<br/>via VPC Connector| VPCConn
    VPCConn --> Router
    Router --> NATGW
    NATGW -->|External APIs| Internet

    %% CI/CD Flow
    DEV -->|Push Code| GH
    GH -->|Use WIF| SA1
    SA1 -->|Build Image| AR
    SA1 -->|Deploy Service| CloudRun
    CloudRun -->|Pull Image| AR

    %% State Management
    GH -->|Terraform State| GCS

    %% Styling
    classDef gcpService fill:#4285f4,stroke:#1a73e8,stroke-width:2px,color:#fff
    classDef network fill:#34a853,stroke:#137333,stroke-width:2px,color:#fff
    classDef security fill:#ea4335,stroke:#c5221f,stroke-width:2px,color:#fff
    classDef external fill:#9aa0a6,stroke:#5f6368,stroke-width:2px,color:#fff
    classDef serverless fill:#fbbc04,stroke:#f9ab00,stroke-width:2px,color:#000

    class LB,CloudSQL,AR,GCS,SM,MON,LOG gcpService
    class CloudRun serverless
    class Router,NATGW,VPCConn,FW network
    class SA1,SA2,WIF,SSL security
    class Users,DNS,GH,DEV external
```

### アーキテクチャの特徴

**ネットワーク構成**

- Cloud RunはGoogleのサーバーレスプラットフォーム上で動作（VPCサブネット内ではない）
- VPC Access ConnectorでCloud RunからVPC内リソースへのアウトバウンド接続を実現
- VPCネットワーク内にパブリック・プライベートサブネットを分離
- Cloud Routerで外部接続を制御、Cloud NATで外部アクセスを実現

**セキュリティ**

- Cloud SQLをプライベートサブネット内に配置
- VPC Access ConnectorでCloud RunからCloud SQLへの安全な接続
- Workload Identity Federationで安全なCI/CD認証

**スケーラビリティ**

- Cloud Runによる自動スケーリング
- Global Load Balancerでの負荷分散
- Artifact Registryでのコンテナ管理
