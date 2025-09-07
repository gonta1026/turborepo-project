package middleware

import (
	"api/config"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CORS(cfg *config.Config) gin.HandlerFunc {
	var allowedOrigins []string
	switch cfg.Environment {
	case "production":
		allowedOrigins = []string{"https://dashboard.my-learn-iac-sample.site"}
	case "development":
		allowedOrigins = []string{"http://localhost:5173", "https://dev.dashboard.my-learn-iac-sample.site"}
	case "test":
		// テスト環境では全てのオリジンを許可
		allowedOrigins = []string{"*"}
	}

	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")

		// テスト環境では常に許可
		if cfg.Environment == "test" {
			c.Header("Access-Control-Allow-Origin", "*")
			c.Header("Access-Control-Allow-Credentials", "true")
		} else {
			// リクエストのOriginが許可リストに含まれているか確認
			isAllowed := false
			for _, allowedOrigin := range allowedOrigins {
				if origin == allowedOrigin {
					isAllowed = true
					break
				}
			}

			// 許可されたOriginの場合のみCORSヘッダーを設定
			if isAllowed {
				c.Header("Access-Control-Allow-Origin", origin)
				c.Header("Access-Control-Allow-Credentials", "true")
			}
		}

		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}
