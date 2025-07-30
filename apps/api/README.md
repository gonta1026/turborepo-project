# API Server

Go + Gin フレームワークを使用したAPIサーバーです。

## 機能

- RESTful API エンドポイント
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

## 開発

### 必要な環境

- Go 1.22以上

### 開発サーバーの起動

```bash
# turborepoのルートから
npm run dev
# またはこのディレクトリから
npm run dev
# または
go run main.go
```

### ビルド

```bash
npm run build
```

### テスト

```bash
npm test
```

### フォーマット・リント

```bash
npm run format-and-lint
npm run format-and-lint:fix
```

## Docker

### イメージのビルド

```bash
docker build -t api-server .
```

### コンテナの実行

```bash
docker run -p 8080:8080 api-server
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
