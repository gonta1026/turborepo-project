package test

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/DATA-DOG/go-txdb"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

const (
	transactionDBDriver = "postgres"
	transactionDBAlias  = "txdb"
)

// buildConnectionString creates a connection string from environment variables
func buildConnectionString() string {
	host := getEnvOrDefault("DB_HOST", "localhost")
	port := getEnvOrDefault("DB_PORT", "5432")
	user := getEnvOrDefault("DB_USER", "apiuser")
	password := getEnvOrDefault("DB_PASSWORD", "apipassword")
	dbname := getEnvOrDefault("DB_NAME", "apidb")
	
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", 
		user, password, host, port, dbname)
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func init() {
	// Build connection string from environment variables
	connectionStr := buildConnectionString()
	log.Printf("Using connection string (password hidden): %s", 
		fmt.Sprintf("postgres://%s:***@%s:%s/%s?sslmode=disable",
			getEnvOrDefault("DB_USER", "apiuser"),
			getEnvOrDefault("DB_HOST", "localhost"), 
			getEnvOrDefault("DB_PORT", "5432"),
			getEnvOrDefault("DB_NAME", "apidb")))
	
	// Register txdb driver for transaction-based testing
	txdb.Register(transactionDBAlias, transactionDBDriver, connectionStr)
	log.Println("Registered txdb driver for testing")
}

// SetupTestDB creates a new test database connection with transaction isolation
// Each test runs in its own transaction that is automatically rolled back
func SetupTestDB() (*sqlx.DB, func()) {
	// Generate a unique ID for this test's transaction
	testID := uuid.New().String()
	
	// Open a connection using txdb
	rawDB, err := sql.Open(transactionDBAlias, testID)
	if err != nil {
		panic(fmt.Sprintf("Failed to open test database: %v", err))
	}
	
	db := sqlx.NewDb(rawDB, transactionDBDriver)
	
	// Verify connection
	if err := db.Ping(); err != nil {
		panic(fmt.Sprintf("Failed to ping test database: %v", err))
	}
	
	cleanup := func() {
		if err := db.Close(); err != nil {
			log.Printf("Failed to close test database: %v", err)
		}
	}
	
	return db, cleanup
}

// Note: With txdb, we don't need TruncateTables because each test runs in an isolated transaction
// that is automatically rolled back at the end of the test