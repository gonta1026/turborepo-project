package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// setupRouter creates a router for testing
func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.Default()

	// CORS設定
	r.Use(func(c *gin.Context) {
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
	}
	return r
}

func TestHealthCheck(t *testing.T) {
	router := setupRouter()

	// リクエスト作成
	req, _ := http.NewRequest("GET", "/health", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// レスポンス検証
	assert.Equal(t, http.StatusOK, w.Code)

	var response HealthResponse
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "healthy", response.Status)
	assert.Equal(t, "API server is running", response.Message)
}

func TestHelloAPI(t *testing.T) {
	router := setupRouter()

	t.Run("デフォルトの挨拶", func(t *testing.T) {
		req, _ := http.NewRequest("GET", "/api/v1/hello", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var response APIResponse
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.Equal(t, "Hello from Go API!", response.Message)

		// Dataフィールドの検証
		data := response.Data.(map[string]interface{})
		assert.Equal(t, "Hello, World!", data["greeting"])
	})

	t.Run("カスタム名での挨拶", func(t *testing.T) {
		req, _ := http.NewRequest("GET", "/api/v1/hello?name=Alice", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var response APIResponse
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.Equal(t, "Hello from Go API!", response.Message)

		// Dataフィールドの検証
		data := response.Data.(map[string]interface{})
		assert.Equal(t, "Hello, Alice!", data["greeting"])
	})
}

func TestUsersAPI(t *testing.T) {
	router := setupRouter()

	t.Run("ユーザー一覧取得", func(t *testing.T) {
		req, _ := http.NewRequest("GET", "/api/v1/users", nil)
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		var response APIResponse
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.Equal(t, "Users retrieved successfully", response.Message)

		// Dataフィールドの検証
		users := response.Data.([]interface{})
		assert.Len(t, users, 2)

		// 最初のユーザーの検証
		firstUser := users[0].(map[string]interface{})
		assert.Equal(t, float64(1), firstUser["id"])
		assert.Equal(t, "John Doe", firstUser["name"])
		assert.Equal(t, "john@example.com", firstUser["email"])
	})

	t.Run("ユーザー作成", func(t *testing.T) {
		newUser := gin.H{
			"name":  "Bob Johnson",
			"email": "bob@example.com",
		}

		jsonData, _ := json.Marshal(newUser)
		req, _ := http.NewRequest("POST", "/api/v1/users", bytes.NewBuffer(jsonData))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		var response APIResponse
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.Equal(t, "User created successfully", response.Message)

		// 作成されたユーザーの検証
		createdUser := response.Data.(map[string]interface{})
		assert.Equal(t, float64(3), createdUser["id"])
		assert.Equal(t, "Bob Johnson", createdUser["name"])
		assert.Equal(t, "bob@example.com", createdUser["email"])
	})

	t.Run("不正なJSONでユーザー作成", func(t *testing.T) {
		invalidJSON := "invalid json"
		req, _ := http.NewRequest("POST", "/api/v1/users", bytes.NewBufferString(invalidJSON))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)

		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.Contains(t, response["error"], "invalid character")
	})
}

func TestCORSHeaders(t *testing.T) {
	router := setupRouter()

	req, _ := http.NewRequest("OPTIONS", "/health", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNoContent, w.Code)
	assert.Equal(t, "*", w.Header().Get("Access-Control-Allow-Origin"))
	assert.Equal(t, "GET, POST, PUT, DELETE, OPTIONS", w.Header().Get("Access-Control-Allow-Methods"))
	assert.Equal(t, "Content-Type, Authorization", w.Header().Get("Access-Control-Allow-Headers"))
}
