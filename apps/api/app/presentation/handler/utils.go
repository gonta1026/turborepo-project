package handler

import (
	"api/app/presentation/request"
	"api/app/presentation/response"

	"github.com/gin-gonic/gin"
)

// HandleValidationError はバリデーションエラーをレスポンスに変換する共通関数
func HandleValidationError(c *gin.Context, validationDetails []request.ValidationErrorDetail) {
	var responseDetails []response.ValidationErrorDetail
	for _, d := range validationDetails {
		responseDetails = append(responseDetails, response.ValidationErrorDetail{
			Field:   d.Field,
			Message: d.Message,
		})
	}
	response.ValidationError(c, responseDetails)
}