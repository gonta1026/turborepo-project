package handler

import (
	"api/app/presentation/request"
	"api/app/presentation/response"
	"api/app/usecase"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type TodoHandler struct {
	todoUsecase usecase.TodoUsecase
}

func NewTodoHandler(todoUsecase usecase.TodoUsecase) *TodoHandler {
	return &TodoHandler{
		todoUsecase: todoUsecase,
	}
}

// GetTodos retrieves all todos
// @Summary Get all todos
// @Description Get a list of all todos
// @Tags todos
// @Accept json
// @Produce json
// @Success 200 {object} handler.APIResponse{data=[]response.TodoResponse}
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/todos [get]
func (h *TodoHandler) GetTodos(c *gin.Context) {
	todos, err := h.todoUsecase.GetAllTodos()
	if err != nil {
		response.InternalServerError(c, "TODO一覧の取得に失敗しました")
		return
	}
	todoResponses := make([]response.TodoResponse, len(todos))
	for i, todo := range todos {
		todoResponses[i] = response.ToTodoResponse(todo)
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "Todo一覧を正常に取得しました",
		"data":    todoResponses,
	})
}

// GetTodo retrieves a single todo by ID
// @Summary Get a todo by ID
// @Description Get a single todo by its ID
// @Tags todos
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} handler.APIResponse{data=response.TodoResponse}
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/todos/{id} [get]
func (h *TodoHandler) GetTodo(c *gin.Context) {
	req, err := request.NewGetByIDRequest(c)
	if err != nil {
		response.ValidationError(c, []response.ValidationErrorDetail{
			{Field: "id", Message: "指定されたIDが無効です"},
		})
		return
	}

	todo, err := h.todoUsecase.GetTodoByID(req.ID)
	if err != nil {
		if errors.Is(err, usecase.ErrTodoNotFound) {
			response.NotFoundError(c, "指定されたTodo")
			return
		}
		if errors.Is(err, usecase.ErrInvalidInput) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "入力データが無効です"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Todoの取得に失敗しました"})
		return
	}

	todoResponse := response.ToTodoResponse(*todo)
	c.JSON(http.StatusOK, gin.H{
		"message": "Todoを正常に取得しました",
		"data":    todoResponse,
	})
}

// CreateTodo creates a new todo
// @Summary Create a new todo
// @Description Create a new todo item
// @Tags todos
// @Accept json
// @Produce json
// @Param todo body request.CreateTodoRequest true "Create todo request"
// @Success 201 {object} handler.APIResponse{data=response.TodoResponse}
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/todos [post]
func (h *TodoHandler) CreateTodo(c *gin.Context) {
	// バリデーション付きリクエスト作成
	req, validationDetails, err := request.NewCreateTodoRequest(c)
	if err != nil {
		response.InvalidJSONError(c)
		return
	}
	// バリデーションエラーがある場合
	if validationDetails != nil {
		HandleValidationError(c, validationDetails)
		return
	}
	// model変換してusecaseに渡す
	todoModel, err := req.Todo()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "処理中にエラーが発生しました"})
		return
	}
	todo, err := h.todoUsecase.CreateTodo(todoModel)
	if err != nil {
		if errors.Is(err, usecase.ErrInvalidInput) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "入力データが無効です"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Todoの作成に失敗しました"})
		return
	}
	todoResponse := response.ToTodoResponse(*todo)
	c.JSON(http.StatusCreated, gin.H{
		"message": "Todoが正常に作成されました",
		"data":    todoResponse,
	})
}

// UpdateTodo updates an existing todo
// @Summary Update a todo
// @Description Update an existing todo item
// @Tags todos
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param todo body request.UpdateTodoRequest true "Update todo request"
// @Success 200 {object} handler.APIResponse{data=response.TodoResponse}
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/todos/{id} [put]
func (h *TodoHandler) UpdateTodo(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.InvalidIDError(c, "id")
		return
	}
	// バリデーション付きリクエスト作成
	req, validationDetails, err := request.NewUpdateTodoRequest(c)
	if err != nil {
		response.InvalidJSONError(c)
		return
	}
	// バリデーションエラーがある場合
	if validationDetails != nil {
		HandleValidationError(c, validationDetails)
		return
	}
	// model変換してusecaseに渡す
	todoModel, err := req.Todo()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "処理中にエラーが発生しました"})
		return
	}
	todo, err := h.todoUsecase.UpdateTodo(id, todoModel)
	if err != nil {
		if errors.Is(err, usecase.ErrTodoNotFound) {
			response.NotFoundError(c, "指定されたTodo")
			return
		}
		if errors.Is(err, usecase.ErrInvalidInput) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "入力データが無効です"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Todoの更新に失敗しました"})
		return
	}
	todoResponse := response.ToTodoResponse(*todo)
	c.JSON(http.StatusOK, gin.H{
		"message": "Todoが正常に更新されました",
		"data":    todoResponse,
	})
}

// DeleteTodo deletes a todo
// @Summary Delete a todo
// @Description Delete a todo item by its ID
// @Tags todos
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} handler.APIResponse
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/todos/{id} [delete]
func (h *TodoHandler) DeleteTodo(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.InvalidIDError(c, "id")
		return
	}
	err = h.todoUsecase.DeleteTodo(id)
	if err != nil {
		if errors.Is(err, usecase.ErrTodoNotFound) {
			response.NotFoundError(c, "指定されたTodo")
			return
		}
		if errors.Is(err, usecase.ErrInvalidInput) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "入力データが無効です"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Todoの削除に失敗しました"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "Todoを正常に削除しました",
	})
}
