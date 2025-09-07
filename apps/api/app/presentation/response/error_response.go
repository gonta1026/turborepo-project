package response

// ErrorResponse represents an error response
type ErrorResponse struct {
	Message string `json:"message" binding:"required" example:"入力内容に不備があります"`
	// バリデーションエラーがあるときはこちらでまとめて返す
	Details []ValidationErrorDetail `json:"details" binding:"required"`
	Status  int                     `json:"status" binding:"required" example:"400"`
}

// ValidationErrorDetail represents a validation error detail
type ValidationErrorDetail struct {
	Field   string `json:"field" binding:"required" example:"title"`
	Message string `json:"message" binding:"required" example:"タイトルは100文字以内で入力してください"`
}
