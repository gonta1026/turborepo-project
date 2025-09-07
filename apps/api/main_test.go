package main

import (
	"api/app/presentation/router"
	"api/config"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

type APIResponse struct {
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

// setupRouter creates a router for testing
func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)

	// Test configuration
	cfg := &config.Config{
		Environment: "test",
	}

	return router.SetupRouter(cfg)
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
