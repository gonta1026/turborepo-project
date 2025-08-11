package test

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/DATA-DOG/go-txdb"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"
	"github.com/kelseyhightower/envconfig"
	_ "github.com/lib/pq"
)

const (
	transactionDBDriver = "postgres"
	transactionDBAlias  = "txdb"
)

type TestConfig struct {
	DBHost     string `envconfig:"DB_HOST" required:"true"`
	DBPort     string `envconfig:"DB_PORT" required:"true"`
	DBUser     string `envconfig:"DB_USER" required:"true"`
	DBPassword string `envconfig:"DB_PASSWORD" required:"true"`
	DBName     string `envconfig:"DB_NAME" required:"true"`
}

// buildConnectionString creates a connection string from environment variables
func buildConnectionString() string {
	var config TestConfig
	if err := envconfig.Process("", &config); err != nil {
		panic(fmt.Sprintf("Failed to load test config: %v", err))
	}
	
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", 
		config.DBUser, config.DBPassword, config.DBHost, config.DBPort, config.DBName)
}

func init() {
	// Load .env file for local development - try current directory first, then parent directory
	if err := godotenv.Load(); err != nil {
		if err := godotenv.Load("../.env"); err != nil {
			log.Println("No .env file found in test (this is normal in production)")
		}
	}
	
	// Build connection string from environment variables
	connectionStr := buildConnectionString()
	
	// Load config for logging (separate from connection string generation to avoid duplicate processing)
	var config TestConfig
	if err := envconfig.Process("", &config); err != nil {
		panic(fmt.Sprintf("Failed to load test config for logging: %v", err))
	}
	
	log.Printf("Using connection string (password hidden): %s", 
		fmt.Sprintf("postgres://%s:***@%s:%s/%s?sslmode=disable",
			config.DBUser, config.DBHost, config.DBPort, config.DBName))
	
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