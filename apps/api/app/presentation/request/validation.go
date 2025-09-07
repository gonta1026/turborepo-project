package request

// Validatableインターフェース - Validate()メソッドを持つ型を定義
type Validatable interface {
	Validate() ValidationErrors
}

// 汎用的なバリデーション処理関数
// どのリクエスト構造体でも使用可能（ネスト構造にも対応）
func ValidateAndExtractDetails[T Validatable](v T) ([]ValidationErrorDetail, bool) {
	validationErrors := v.Validate()
	if len(validationErrors) == 0 {
		return nil, true
	}

	var details []ValidationErrorDetail
	for _, ve := range validationErrors {
		details = append(details, ValidationErrorDetail{
			Field:   ve.Field,
			Message: ve.Message,
		})
	}
	return details, false
}