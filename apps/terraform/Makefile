

help:
	@echo "🚀 Terraform 操作コマンド"
	@echo ""
	@echo "📋 使用可能なコマンド:"
	@echo "  make help              - このヘルプを表示"
	@echo "  make init-all          - 全環境のterraform init"
	@echo ""
	@echo "🗄️ バックエンド設定:"
	@echo "  make setup-gcs-backend - GCSバックエンド用バケットを作成"
	@echo "  make migrate-to-gcs    - ローカル状態をGCSに移行"
	@echo ""
	@echo "🔧 Dev環境:"
	@echo "  make plan-dev          - dev環境のplan"
	@echo "  make apply-dev         - dev環境のapply"
	@echo "  make destroy-dev       - dev環境のdestroy"
	@echo ""
	
# GCSバックエンド用バケットの作成
setup-gcs-backend:
	@echo "🗄️ GCS バックエンド用バケットを作成します..."
	cd gcp/backend && terraform init
	cd gcp/backend && terraform plan
	cd gcp/backend && terraform apply
	@echo "✅ GCSバックエンド設定完了"

# ローカル状態をGCSに移行
migrate-to-gcs:
	@echo "🔄 ローカル状態ファイルをGCSに移行します..."
	@echo "⚠️  移行前に既存の terraform.tfstate のバックアップを作成することを推奨します"
	cd gcp/environments/dev/setup && cp terraform.tfstate terraform.tfstate.backup 2>/dev/null || true
	cd gcp/environments/dev/setup && terraform init -migrate-state
	@echo "✅ 状態ファイルの移行完了"

# 全環境の初期化
init-all:
	@echo "🔧 全環境のterraform initを実行します..."
	cd gcp/environments/dev/setup && terraform init
	@echo "✅ 初期化完了"

# Dev環境
plan-dev:
	@echo "🔧 Dev環境のplanを実行します..."
	cd gcp/environments/dev/setup && terraform plan && cd ../../..

apply-dev:
	@echo "🚀 Dev環境にapplyします..."
	cd gcp/environments/dev/setup && terraform apply && cd ../../..

destroy-dev:
	@echo "🗑️ Dev環境を削除します..."
	cd gcp/environments/dev/setup && terraform destroy && cd ../../..



	
	


	
	


	
	