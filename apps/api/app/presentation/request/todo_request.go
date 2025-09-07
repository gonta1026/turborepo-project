package request

import (
	"fmt"
	"strings"
	"time"

	"api/app/models"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type CreateTodoRequest struct {
	Title       string `json:"title" validate:"required,max=100" ja:"タイトル"`
	Description string `json:"description" validate:"max=500" ja:"説明"`
	Priority    models.TodoPriority `json:"priority" validate:"omitempty,oneof=low medium high" ja:"優先度"`
}

type UpdateTodoRequest struct {
	Title       string `json:"title" validate:"max=100" ja:"タイトル"`
	Description string `json:"description" validate:"max=500" ja:"説明"`
	Priority    models.TodoPriority `json:"priority" validate:"omitempty,oneof=low medium high" ja:"優先度"`
	Completed   *bool  `json:"completed" ja:"完了状態"`
}

type ValidationError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

type ValidationErrors []ValidationError

func (v ValidationErrors) Error() string {
	var messages []string
	for _, err := range v {
		messages = append(messages, err.Message)
	}
	return strings.Join(messages, ", ")
}

var validate *validator.Validate

func init() {
	validate = validator.New()
}

// バリデーションエラーを日本語メッセージに変換
func translateValidationError(err validator.FieldError, fieldName string) ValidationError {
	switch err.Tag() {
	case "required":
		return ValidationError{
			Field:   err.Field(),
			Message: fmt.Sprintf("%sは必須です", fieldName),
		}
	case "max":
		return ValidationError{
			Field:   err.Field(),
			Message: fmt.Sprintf("%sは%s文字以内で入力してください", fieldName, err.Param()),
		}
	case "oneof":
		return ValidationError{
			Field:   err.Field(),
			Message: fmt.Sprintf("%sは %s のいずれかを指定してください", fieldName, err.Param()),
		}
	default:
		return ValidationError{
			Field:   err.Field(),
			Message: fmt.Sprintf("%sの形式が正しくありません", fieldName),
		}
	}
}

// フィールド名を日本語に変換
func getJapaneseFieldName(structTag string, fieldName string) string {
	// jaタグがあればそれを使用、なければフィールド名をそのまま
	if structTag != "" {
		return structTag
	}
	return fieldName
}

func (r *CreateTodoRequest) Validate() ValidationErrors {
	err := validate.Struct(r)
	if err == nil {
		return nil
	}

	var errors ValidationErrors
	for _, err := range err.(validator.ValidationErrors) {
		// リフレクションでjaタグを取得
		fieldName := getJapaneseFieldName("", err.Field()) // 簡略化版

		switch err.Field() {
		case "Title":
			fieldName = "タイトル"
		case "Description":
			fieldName = "説明"
		case "Priority":
			fieldName = "優先度"
		}

		errors = append(errors, translateValidationError(err, fieldName))
	}
	return errors
}

func (r *UpdateTodoRequest) Validate() ValidationErrors {
	err := validate.Struct(r)
	if err == nil {
		return nil
	}

	var errors ValidationErrors
	for _, err := range err.(validator.ValidationErrors) {
		fieldName := getJapaneseFieldName("", err.Field())

		switch err.Field() {
		case "Title":
			fieldName = "タイトル"
		case "Description":
			fieldName = "説明"
		case "Priority":
			fieldName = "優先度"
		case "Completed":
			fieldName = "完了状態"
		}

		errors = append(errors, translateValidationError(err, fieldName))
	}
	return errors
}

// model変換メソッド（参考実装のSite()スタイルに合わせる）
func (r *CreateTodoRequest) Todo() (*models.Todo, error) {
	// デフォルト値設定
	priority := r.Priority
	if priority == "" {
		priority = models.PriorityMedium
	}

	now := time.Now()

	return &models.Todo{
		Title:       r.Title,
		Description: r.Description,
		Priority:    priority,
		Completed:   false,
		CreatedAt:   now,
		UpdatedAt:   now,
	}, nil
}

func (r *UpdateTodoRequest) Todo() (*models.Todo, error) {
	now := time.Now()

	todo := &models.Todo{
		Title:       r.Title,
		Description: r.Description,
		Priority:    r.Priority,
		UpdatedAt:   now,
	}

	if r.Completed != nil {
		todo.Completed = *r.Completed
	}

	return todo, nil
}

// ValidationErrorDetailをレスポンス用に定義
type ValidationErrorDetail struct {
	Field   string `json:"field" required:"true"`
	Message string `json:"message" required:"true"`
}

// バリデーション処理をrequest内で完結させるヘルパー
func (r *CreateTodoRequest) ValidateAndExtractDetails() ([]ValidationErrorDetail, bool) {
	return ValidateAndExtractDetails(r)
}

func (r *UpdateTodoRequest) ValidateAndExtractDetails() ([]ValidationErrorDetail, bool) {
	return ValidateAndExtractDetails(r)
}

// 参考実装スタイル: バリデーション付きリクエスト作成関数
func NewCreateTodoRequest(c *gin.Context) (*CreateTodoRequest, []ValidationErrorDetail, error) {
	var req CreateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		return nil, nil, err
	}
	// バリデーション実行
	if details, isValid := req.ValidateAndExtractDetails(); !isValid {
		return nil, details, nil
	}

	return &req, nil, nil
}

func NewUpdateTodoRequest(c *gin.Context) (*UpdateTodoRequest, []ValidationErrorDetail, error) {
	var req UpdateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		return nil, nil, err
	}

	// バリデーション実行
	if details, isValid := req.ValidateAndExtractDetails(); !isValid {
		return nil, details, nil
	}

	return &req, nil, nil
}

type GetByIDRequest struct {
	ID int `param:"id" validate:"required"`
}

func NewGetByIDRequest(c *gin.Context) (*GetByIDRequest, error) {
	var req GetByIDRequest
	if err := c.Bind(&req); err != nil {
		return nil, err
	}
	if err := validate.Struct(req); err != nil {
		return nil, err
	}
	return &req, nil
}
