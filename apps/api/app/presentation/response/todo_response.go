package response

import (
	"time"

	"api/app/models"
)

type TodoResponse struct {
	ID          int       `json:"id" binding:"required"`
	Title       string    `json:"title" binding:"required"`
	Description string    `json:"description"`
	Completed   bool      `json:"completed"`
	Priority    models.TodoPriority `json:"priority" binding:"required"`
	CreatedAt   time.Time `json:"created_at" binding:"required"`
	UpdatedAt   time.Time `json:"updated_at" binding:"required"`
}

type TodoListResponse struct {
	Todos []TodoResponse `json:"todos"`
}

// ToTodoResponse converts models.Todo to TodoResponse
func ToTodoResponse(todo models.Todo) TodoResponse {
	return TodoResponse{
		ID:          todo.ID,
		Title:       todo.Title,
		Description: todo.Description,
		Completed:   todo.Completed,
		Priority:    todo.Priority,
		CreatedAt:   todo.CreatedAt,
		UpdatedAt:   todo.UpdatedAt,
	}
}

// ToTodoListResponse converts []models.Todo to TodoListResponse
func ToTodoListResponse(todos []models.Todo) TodoListResponse {
	todoResponses := make([]TodoResponse, len(todos))
	for i, todo := range todos {
		todoResponses[i] = ToTodoResponse(todo)
	}
	return TodoListResponse{
		Todos: todoResponses,
	}
}
