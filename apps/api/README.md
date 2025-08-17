# API Server

Go + Gin フレームワークを使用したAPIサーバーです。

## 機能

- RESTful API エンドポイント
- PostgreSQLデータベース連携
- トランザクションベースのテスト
- レイヤードアーキテクチャ（Handler/Usecase/Repository）
- 環境変数による設定管理
- Cloud SQL対応
- ヘルスチェック機能
- CORS対応
- JSON レスポンス形式

## エンドポイント

### ヘルスチェック

- `GET /health` - サーバーの稼働状況を確認

### API v1

- `GET /api/v1/hello?name=<name>` - 挨拶メッセージを返す
- `GET /api/v1/users` - ユーザー一覧を取得
- `POST /api/v1/users` - 新しいユーザーを作成

### Todo API

- `GET /api/v1/todos` - Todo一覧を取得
- `GET /api/v1/todos/:id` - 特定のTodoを取得
- `POST /api/v1/todos` - 新しいTodoを作成
- `PUT /api/v1/todos/:id` - Todoを更新
- `DELETE /api/v1/todos/:id` - Todoを削除

## 開発

### 必要な環境

- Go 1.23以上
- Docker & Docker Compose
- PostgreSQL（Dockerで提供）

### セットアップ

```bash
# 環境変数ファイルの作成
cp .env.example .env

# Docker環境の起動
make docker-up

# マイグレーションの実行
make migrate-up
```

### 開発サーバーの起動

```bash
# ホットリロード付きで起動（推奨）
make dev
# または
npm run dev

# Docker環境と一緒に起動（通常の実行）
make run-with-docker

# または直接実行
go run main.go
```

### ビルド

```bash
npm run build
```

### テスト

このプロジェクトでは、`go-txdb`を使用してトランザクションベースのテストを実装しています。

- **単一のデータベースを使用**: テスト専用のデータベースを作成する代わりに、開発用のデータベースを使用
- **トランザクション分離**: 各テストは独立したトランザクション内で実行され、テスト終了時に自動的にロールバック
- **テスト間の独立性**: 各テストは他のテストの影響を受けません

```bash
# 全てのテストを実行
make test

# Usecaseレイヤーのテストのみ実行
make test-usecase
```

### フォーマット・リント

```bash
npm run format-and-lint
npm run format-and-lint:fix
```

## アーキテクチャ

```
.
├── handlers/      # HTTPハンドラー層
├── usecase/       # ビジネスロジック層
├── repository/    # データアクセス層
├── models/        # データモデル
├── config/        # 設定管理
├── db/            # データベース接続
├── migrations/    # DBマイグレーション
└── test/          # テストヘルパー
```

## 環境変数

主な環境変数（`.env.example`参照）:

- `DB_HOST`: データベースホスト（デフォルト: localhost）
- `DB_PORT`: データベースポート（デフォルト: 9000）
- `DB_USER`: データベースユーザー
- `DB_PASSWORD`: データベースパスワード
- `DB_NAME`: データベース名
- `USE_CLOUD_SQL`: Cloud SQLを使用するかどうか
- `CLOUD_SQL_INSTANCE`: Cloud SQLインスタンス名

## Docker

### Docker Composeでの起動

```bash
# サービスの起動
make docker-up

# サービスの停止
make docker-down
```

## API使用例

### ヘルスチェック

```bash
curl http://localhost:8080/health
```

### Hello API

```bash
curl "http://localhost:8080/api/v1/hello?name=John"
```

### ユーザー一覧取得

```bash
curl http://localhost:8080/api/v1/users
```

### ユーザー作成

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'
```

### Todo作成

```bash
curl -X POST http://localhost:8080/api/v1/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "買い物", "description": "牛乳を買う"}'
```

### Todo一覧取得

```bash
curl http://localhost:8080/api/v1/todos
```

## マイグレーション

```bash
# マイグレーションを実行
make migrate-up

# マイグレーションをロールバック
make migrate-down

# 新しいマイグレーションファイルを作成
migrate create -ext sql -dir migrations -seq <migration_name>
```
