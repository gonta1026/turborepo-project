package repository

import (
	"api/models"
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
)

var ErrNoRows = sql.ErrNoRows

type TodoRepository interface {
	GetAll() ([]models.Todo, error)
	GetByID(id int) (*models.Todo, error)
	Create(title, description string) (*models.Todo, error)
	Update(id int, title, description string, completed *bool) (*models.Todo, error)
	Delete(id int) error
}

type todoRepository struct {
	db *sqlx.DB
}

func NewTodoRepository(db *sqlx.DB) TodoRepository {
	return &todoRepository{db: db}
}

func (r *todoRepository) GetAll() ([]models.Todo, error) {
	var todos []models.Todo
	query := `SELECT id, title, description, completed, created_at, updated_at FROM todos ORDER BY created_at DESC`
	
	err := r.db.Select(&todos, query)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch todos: %w", err)
	}

	return todos, nil
}

func (r *todoRepository) GetByID(id int) (*models.Todo, error) {
	var todo models.Todo
	query := `SELECT id, title, description, completed, created_at, updated_at FROM todos WHERE id = $1`
	
	err := r.db.Get(&todo, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to fetch todo: %w", err)
	}

	return &todo, nil
}

func (r *todoRepository) Create(title, description string) (*models.Todo, error) {
	var todo models.Todo
	query := `
		INSERT INTO todos (title, description, completed, created_at, updated_at) 
		VALUES ($1, $2, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
		RETURNING id, title, description, completed, created_at, updated_at`
	
	err := r.db.QueryRowx(query, title, description).StructScan(&todo)
	if err != nil {
		return nil, fmt.Errorf("failed to create todo: %w", err)
	}

	return &todo, nil
}

func (r *todoRepository) Update(id int, title, description string, completed *bool) (*models.Todo, error) {
	// Build dynamic update query
	query := `UPDATE todos SET updated_at = CURRENT_TIMESTAMP`
	args := []interface{}{}
	argCount := 1

	if title != "" {
		query += fmt.Sprintf(`, title = $%d`, argCount)
		args = append(args, title)
		argCount++
	}

	if description != "" {
		query += fmt.Sprintf(`, description = $%d`, argCount)
		args = append(args, description)
		argCount++
	}

	if completed != nil {
		query += fmt.Sprintf(`, completed = $%d`, argCount)
		args = append(args, *completed)
		argCount++
	}

	query += fmt.Sprintf(` WHERE id = $%d RETURNING id, title, description, completed, created_at, updated_at`, argCount)
	args = append(args, id)

	var todo models.Todo
	err := r.db.QueryRowx(query, args...).StructScan(&todo)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to update todo: %w", err)
	}

	return &todo, nil
}

func (r *todoRepository) Delete(id int) error {
	query := `DELETE FROM todos WHERE id = $1`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete todo: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}