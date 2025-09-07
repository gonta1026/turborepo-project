package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// 統一エラーレスポンス構造
type UnifiedErrorResponse struct {
	Message   string                  `json:"message"`    // エラーメッセージ
	ErrorCode string                  `json:"error_code"` // エラーコード（フロント処理用）
	Details   []ValidationErrorDetail `json:"details"`    // バリデーションエラー詳細
}

// エラーコード定数
const (
	// Presentation層のエラー
	ErrorCodeValidation     = "VALIDATION_ERROR"
	ErrorCodeInvalidJSON    = "INVALID_JSON"
	ErrorCodeInvalidRequest = "INVALID_REQUEST"
	ErrorCodeInvalidID      = "INVALID_ID"

	// Usecase層のエラー
	ErrorCodeNotFound      = "NOT_FOUND"
	ErrorCodeAlreadyExists = "ALREADY_EXISTS"
	ErrorCodeUnauthorized  = "UNAUTHORIZED"
	ErrorCodeForbidden     = "FORBIDDEN"
	ErrorCodeBusinessRule  = "BUSINESS_RULE_VIOLATION"

	// Infrastructure層のエラー
	ErrorCodeDatabaseError  = "DATABASE_ERROR"
	ErrorCodeExternalAPI    = "EXTERNAL_API_ERROR"
	ErrorCodeInternalServer = "INTERNAL_SERVER_ERROR"
)

// Presentation層エラー（バリデーションエラー）
func ValidationError(c *gin.Context, details []ValidationErrorDetail) {
	c.JSON(http.StatusBadRequest, UnifiedErrorResponse{
		Message:   "入力内容に不備があります",
		ErrorCode: ErrorCodeValidation,
		Details:   details,
	})
}

// Presentation層エラー（JSONエラー）
func InvalidJSONError(c *gin.Context) {
	c.JSON(http.StatusBadRequest, UnifiedErrorResponse{
		Message:   "不正なJSON形式です",
		ErrorCode: ErrorCodeInvalidJSON,
		Details:   []ValidationErrorDetail{},
	})
}

// Presentation層エラー（IDエラー）
func InvalidIDError(c *gin.Context, fieldName string) {
	c.JSON(http.StatusBadRequest, UnifiedErrorResponse{
		Message:   "無効なIDです",
		ErrorCode: ErrorCodeInvalidID,
		Details:   []ValidationErrorDetail{},
	})
}

// Usecase層エラー（リソースが見つからない）
func NotFoundError(c *gin.Context, resource string) {
	c.JSON(http.StatusNotFound, UnifiedErrorResponse{
		Message:   resource + "が見つかりません",
		ErrorCode: ErrorCodeNotFound,
		Details:   []ValidationErrorDetail{},
	})
}

// Usecase層エラー（既に存在する）
func AlreadyExistsError(c *gin.Context, resource string) {
	c.JSON(http.StatusConflict, UnifiedErrorResponse{
		Message:   resource + "は既に存在します",
		ErrorCode: ErrorCodeAlreadyExists,
		Details:   []ValidationErrorDetail{},
	})
}

// Usecase層エラー（認証エラー）
func UnauthorizedError(c *gin.Context, message string) {
	c.JSON(http.StatusUnauthorized, UnifiedErrorResponse{
		Message:   message,
		ErrorCode: ErrorCodeUnauthorized,
		Details:   []ValidationErrorDetail{},
	})
}

// Usecase層エラー（権限エラー）
func ForbiddenError(c *gin.Context, message string) {
	c.JSON(http.StatusForbidden, UnifiedErrorResponse{
		Message:   message,
		ErrorCode: ErrorCodeForbidden,
		Details:   []ValidationErrorDetail{},
	})
}

// Usecase層エラー（ビジネスルール違反）
func BusinessRuleError(c *gin.Context, message string) {
	c.JSON(http.StatusUnprocessableEntity, UnifiedErrorResponse{
		Message:   message,
		ErrorCode: ErrorCodeBusinessRule,
	})
}

// Infrastructure層エラー（データベースエラー）
func DatabaseError(c *gin.Context) {
	c.JSON(http.StatusInternalServerError, UnifiedErrorResponse{
		Message:   "データベースエラーが発生しました",
		ErrorCode: ErrorCodeDatabaseError,
	})
}

// Infrastructure層エラー（外部API呼び出しエラー）
func ExternalAPIError(c *gin.Context, message string) {
	c.JSON(http.StatusBadGateway, UnifiedErrorResponse{
		Message:   message,
		ErrorCode: ErrorCodeExternalAPI,
	})
}

// Infrastructure層エラー（内部サーバーエラー）
func InternalServerError(c *gin.Context, message string) {
	c.JSON(http.StatusInternalServerError, UnifiedErrorResponse{
		Message:   message,
		ErrorCode: ErrorCodeInternalServer,
		Details:   []ValidationErrorDetail{},
	})
}
