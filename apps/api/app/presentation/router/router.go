package router

import (
	"api/app/container"
	"api/app/middleware"
	"api/config"
	"api/db"
	"os"

	_ "api/docs"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(cfg *config.Config) *gin.Engine {
	r := gin.Default()

	// CORS設定
	r.Use(middleware.CORS(cfg))

	if cfg.Environment == "development" {
		// Swagger documentation endpoint
		r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	}
	// InitializeHandlersでハンドラーを一括初期化
	var handlers *container.Handlers
	if db.DB != nil {
		handlers = container.InitializeHandlers(db.DB, cfg)
	}
	// ヘルスチェックエンドポイント
	if handlers != nil && handlers.Health != nil {
		r.GET("/health", handlers.Health.HealthCheck)
	}
	// API v1 グループ
	v1 := r.Group("/api/v1")
	{
		if handlers != nil && handlers.Simple != nil {
			v1.GET("/hello", handlers.Simple.Hello)
			v1.GET("/users", handlers.Simple.GetUsers)
			v1.POST("/users", handlers.Simple.CreateUser)
		}

		// Todo CRUD endpoints
		if handlers != nil && handlers.Todo != nil {
			todos := v1.Group("/todos")
			{
				todos.GET("", handlers.Todo.GetTodos)
				todos.GET("/:id", handlers.Todo.GetTodo)
				todos.POST("", handlers.Todo.CreateTodo)
				todos.PUT("/:id", handlers.Todo.UpdateTodo)
				todos.DELETE("/:id", handlers.Todo.DeleteTodo)
			}
		}
	}

	return r
}

func StartServer(r *gin.Engine) error {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	return r.Run(":" + port)
}
