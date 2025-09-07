package server

import (
	"api/app/presentation/router"
	"api/config"
	"api/db"
	"log"

	"github.com/joho/godotenv"
)

func Initialize() error {
	// Load .env file for local development (ignore errors in production)
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found (this is normal in production)")
	}

	// Load configuration from environment variables
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	// Initialize database
	if err := db.InitDB(cfg); err != nil {
		return err
	}

	return nil
}

func Start() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	r := router.SetupRouter(cfg)
	return router.StartServer(r)
}

func Shutdown() {
	db.CloseDB()
}
