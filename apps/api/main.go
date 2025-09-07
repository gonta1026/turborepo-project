package main

import (
	"api/app/server"
	"log"
)

// @title Todo API
// @version 1.0
// @description A simple todo API built with Go and Gin framework
// @host localhost:8080
// @BasePath /
// @schemes http https
func main() {
	// Initialize server dependencies
	if err := server.Initialize(); err != nil {
		log.Fatal("Failed to initialize server: ", err)
	}
	defer server.Shutdown()

	// Start server
	log.Println("Starting server...")
	if err := server.Start(); err != nil {
		log.Fatal("Failed to start server: ", err)
	}
}
