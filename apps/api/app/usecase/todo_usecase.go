package usecase

import (
	"api/app/external"
	"api/app/models"
	"api/repository"
	"context"
	"errors"
	"fmt"
)

var (
	ErrTodoNotFound = errors.New("todo not found")
	ErrInvalidInput = errors.New("invalid input")
)

type TodoUsecase interface {
	GetAllTodos() ([]models.Todo, error)
	GetTodoByID(id int) (*models.Todo, error)
	CreateTodo(todo *models.Todo) (*models.Todo, error)
	UpdateTodo(id int, todo *models.Todo) (*models.Todo, error)
	DeleteTodo(id int) error
}

type todoUsecase struct {
	todoRepo           repository.TodoRepository
	notificationClient external.NotificationClient
}

func NewTodoUsecase(todoRepo repository.TodoRepository, notificationClient external.NotificationClient) TodoUsecase {
	return &todoUsecase{
		todoRepo:           todoRepo,
		notificationClient: notificationClient,
	}
}

func (u *todoUsecase) GetAllTodos() ([]models.Todo, error) {
	todos, err := u.todoRepo.GetAll()
	if err != nil {
		return nil, err
	}
	// Return empty slice instead of nil for consistency
	if todos == nil {
		todos = []models.Todo{}
	}
	return todos, nil
}

func (u *todoUsecase) GetTodoByID(id int) (*models.Todo, error) {
	if id <= 0 {
		return nil, ErrInvalidInput
	}

	todo, err := u.todoRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if todo == nil {
		return nil, ErrTodoNotFound
	}

	return todo, nil
}

func (u *todoUsecase) CreateTodo(todo *models.Todo) (*models.Todo, error) {
	if todo.Title == "" {
		return nil, ErrInvalidInput
	}

	// Validate priority
	if todo.Priority != "" && todo.Priority != "low" && todo.Priority != "medium" && todo.Priority != "high" {
		return nil, ErrInvalidInput
	}

	// Set default priority
	if todo.Priority == "" {
		todo.Priority = "medium"
	}

	// Create todo in database
	createdTodo, err := u.todoRepo.Create(todo.Title, todo.Description, todo.Priority)
	if err != nil {
		return nil, err
	}

	// Send notification (外部API呼び出し)
	ctx := context.Background()
	notificationReq := &external.NotificationRequest{
		UserID:  1, // 固定値（実際は認証ユーザーIDを使用）
		Title:   "新しいTodoが作成されました",
		Message: fmt.Sprintf("「%s」が作成されました。優先度: %s", createdTodo.Title, createdTodo.Priority),
		Type:    "push",
	}

	// 通知送信（エラーが発生してもTodo作成は成功として扱う）
	_, notifErr := u.notificationClient.SendNotification(ctx, notificationReq)
	if notifErr != nil {
		// ログに記録するだけで、エラーは返さない
		fmt.Printf("Failed to send notification: %v\n", notifErr)
	}

	return createdTodo, nil
}

func (u *todoUsecase) UpdateTodo(id int, todo *models.Todo) (*models.Todo, error) {
	if id <= 0 {
		return nil, ErrInvalidInput
	}

	// Check if todo exists
	existingTodo, err := u.todoRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if existingTodo == nil {
		return nil, ErrTodoNotFound
	}

	// Validate priority
	if todo.Priority != "" && todo.Priority != "low" && todo.Priority != "medium" && todo.Priority != "high" {
		return nil, ErrInvalidInput
	}

	// Update with provided values
	updatedTodo, err := u.todoRepo.Update(id, todo.Title, todo.Description, todo.Priority, &todo.Completed)
	if err != nil {
		return nil, err
	}

	if updatedTodo == nil {
		return nil, ErrTodoNotFound
	}

	return updatedTodo, nil
}

func (u *todoUsecase) DeleteTodo(id int) error {
	if id <= 0 {
		return ErrInvalidInput
	}

	err := u.todoRepo.Delete(id)
	if err != nil {
		if errors.Is(err, repository.ErrNoRows) {
			return ErrTodoNotFound
		}
		return err
	}

	return nil
}
