# `Turborepo` Vite スターター

### アプリとパッケージ

- `dashboard`: React [Vite](https://vitejs.dev) TypeScriptアプリ
- `api`: Go Ginフレームワークを使用したAPIサーバー
- `terraform`: GCPリソース管理用のTerraform設定
- `@repo/ui`: `dashboard`アプリケーションで共有されるコンポーネントライブラリ
- `@repo/biome-config`: 共有された`Biome`設定
- `@repo/typescript-config`: モノレポ全体で使用される`tsconfig.json`

各パッケージとアプリは100% [TypeScript](https://www.typescriptlang.org/)です（APIアプリはGoです）。

### ツール

このTurborepoには以下のツールがあらかじめ設定されています：

- [TypeScript](https://www.typescriptlang.org/) 静的型チェック用
- [Biome](https://biomejs.dev/) コードのリントとフォーマット用
- [Vite](https://vitejs.dev/) フロントエンドビルドツール
- [Vitest](https://vitest.dev/) フロントエンドテスト用
- [Go](https://golang.org/) バックエンドAPI開発用
- [Gin](https://gin-gonic.com/) Go Webフレームワーク
- [Terraform](https://www.terraform.io/) インフラストラクチャ・アズ・コード

### 開発コマンド

#### アプリケーション開発

```sh
# 開発サーバーを起動
npm run dev

# プロジェクトをビルド
npm run build

# テストを実行
npm run test

# コードのフォーマットとリント
npm run format-and-lint

# コードのフォーマットとリント（自動修正）
npm run format-and-lint:fix
```

#### インフラ管理

```sh
# Terraform初期設定（初回のみ）
npm run infra:setup

# Dev環境のプラン確認
npm run infra:dev:plan

# Dev環境にデプロイ
npm run infra:dev:apply

# Dev環境を削除
npm run infra:dev:destroy

# Terraformフォーマット
npm run terraform:format

# Terraform設定の検証
npm run terraform:validate
```
