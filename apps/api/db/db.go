package db

import (
	"api/config"
	"fmt"
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var DB *sqlx.DB

func InitDB(cfg *config.Config) error {
	dsn := cfg.GetDSN()

	var err error
	DB, err = sqlx.Connect("postgres", dsn)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	if err = DB.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("Successfully connected to database")

	// NOTE: Migrations are now handled by CI/CD pipeline (GitHub Actions)
	// Manual migration command: migrate -path ./migrations -database $DATABASE_URL up

	return nil
}

// runMigrations function removed - migrations now handled by CI/CD pipeline
// For manual migration: migrate -path ./migrations -database $DATABASE_URL up

func CloseDB() {
	if DB != nil {
		DB.Close()
	}
}