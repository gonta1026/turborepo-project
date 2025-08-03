package main

import (
	"api/config"
	"api/db"
	"api/handlers"
	"api/repository"
	"api/usecase"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

type APIResponse struct {
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	if err := db.InitDB(cfg); err != nil {
		log.Fatal("Failed to initialize database: ", err)
	}
	defer db.CloseDB()

	// Ginのルーターを初期化
	r := gin.Default()

	// CORS設定
	r.Use(func(c *gin.Context) {
		// TODO: 本番環境では設定を変更する
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	})

	// ヘルスチェックエンドポイント
	r.GET("/health", func(c *gin.Context) {
		response := HealthResponse{
			Status:  "healthy",
			Message: "API server is running",
		}
		c.JSON(http.StatusOK, response)
	})

	// API v1 グループ
	v1 := r.Group("/api/v1")
	{
		v1.GET("/hello", func(c *gin.Context) {
			name := c.DefaultQuery("name", "World")
			response := APIResponse{
				Message: "Hello from Go API!",
				Data:    gin.H{"greeting": "Hello, " + name + "!"},
			}
			c.JSON(http.StatusOK, response)
		})

		v1.GET("/users", func(c *gin.Context) {
			// サンプルユーザーデータ
			users := []gin.H{
				{"id": 1, "name": "John Doe", "email": "john@example.com"},
				{"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
			}
			response := APIResponse{
				Message: "Users retrieved successfully",
				Data:    users,
			}
			c.JSON(http.StatusOK, response)
		})

		v1.POST("/users", func(c *gin.Context) {
			var newUser gin.H
			if err := c.ShouldBindJSON(&newUser); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}

			// IDを追加（実際のアプリではDBで自動生成）
			newUser["id"] = 3
			response := APIResponse{
				Message: "User created successfully",
				Data:    newUser,
			}
			c.JSON(http.StatusCreated, response)
		})

		// Initialize repository, usecase, and handler
		todoRepo := repository.NewTodoRepository(db.DB)
		todoUsecase := usecase.NewTodoUsecase(todoRepo)
		todoHandler := handlers.NewTodoHandler(todoUsecase)

		// Todo CRUD endpoints
		todos := v1.Group("/todos")
		{
			todos.GET("", todoHandler.GetTodos)
			todos.GET("/:id", todoHandler.GetTodo)
			todos.POST("", todoHandler.CreateTodo)
			todos.PUT("/:id", todoHandler.UpdateTodo)
			todos.DELETE("/:id", todoHandler.DeleteTodo)
		}
	}

	// サーバー起動
	port := ":8080"
	log.Printf("Starting server on port %s", port)
	if err := r.Run(port); err != nil {
		log.Fatal("Failed to start server: ", err)
	}
}
