package usecase

import (
	"api/models"
	"api/repository"
	"errors"
)

var (
	ErrTodoNotFound = errors.New("todo not found")
	ErrInvalidInput = errors.New("invalid input")
)

type TodoUsecase interface {
	GetAllTodos() ([]models.Todo, error)
	GetTodoByID(id int) (*models.Todo, error)
	CreateTodo(req *models.CreateTodoRequest) (*models.Todo, error)
	UpdateTodo(id int, req *models.UpdateTodoRequest) (*models.Todo, error)
	DeleteTodo(id int) error
}

type todoUsecase struct {
	todoRepo repository.TodoRepository
}

func NewTodoUsecase(todoRepo repository.TodoRepository) TodoUsecase {
	return &todoUsecase{
		todoRepo: todoRepo,
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

func (u *todoUsecase) CreateTodo(req *models.CreateTodoRequest) (*models.Todo, error) {
	if req.Title == "" {
		return nil, ErrInvalidInput
	}

	todo, err := u.todoRepo.Create(req.Title, req.Description)
	if err != nil {
		return nil, err
	}

	return todo, nil
}

func (u *todoUsecase) UpdateTodo(id int, req *models.UpdateTodoRequest) (*models.Todo, error) {
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

	// Update with provided values
	todo, err := u.todoRepo.Update(id, req.Title, req.Description, req.Completed)
	if err != nil {
		return nil, err
	}

	if todo == nil {
		return nil, ErrTodoNotFound
	}

	return todo, nil
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