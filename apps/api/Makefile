.PHONY: migrate-up migrate-down migrate-create docker-up docker-down test

# Migration commands (ローカル開発用 - ハードコーディング)

migrate-up:
	migrate -path migrations -database "postgres://apiuser:apipassword@localhost:9000/apidb?sslmode=disable" up

migrate-down:
	migrate -path migrations -database "postgres://apiuser:apipassword@localhost:9000/apidb?sslmode=disable" down

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

test:
	go test -v ./...
