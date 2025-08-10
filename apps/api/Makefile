.PHONY: migrate-up migrate-down migrate-create docker-up docker-down test

# Migration commands (ローカル開発用)

migrate-up:
	@set -a && . .env && set +a && migrate -path migrations -database "postgres://$$DB_USER:$$DB_PASSWORD@$$DB_HOST:$$DB_PORT/$$DB_NAME?sslmode=disable" up

migrate-down:
	@set -a && . .env && set +a && migrate -path migrations -database "postgres://$$DB_USER:$$DB_PASSWORD@$$DB_HOST:$$DB_PORT/$$DB_NAME?sslmode=disable" down

migrate-create:
	@read -p "Enter migration name: " name; \
	migrate create -ext sql -dir migrations -seq $$name

# Docker commands
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

# Run the application with docker
run-with-docker: docker-up
	go run main.go

# Test commands (ローカル開発用 - .env.testから環境変数を読み込み)
test:
	@echo "Running tests with transaction isolation..."
	@set -a && . .env.test && set +a && go test -v ./...

test-usecase:
	@echo "Running usecase tests with transaction isolation..."
	@set -a && . .env.test && set +a && go test -v ./usecase/...