package usecase_test

import (
	"api/models"
	"api/repository"
	"api/test"
	"api/usecase"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMain(m *testing.M) {
	// Run tests
	m.Run()
}

func setupTest(_ *testing.T) (usecase.TodoUsecase, func()) {
	// Get a test database connection with transaction isolation
	db, cleanup := test.SetupTestDB()

	// Create repository and usecase with real database
	todoRepo := repository.NewTodoRepository(db)
	todoUsecase := usecase.NewTodoUsecase(todoRepo)

	return todoUsecase, cleanup
}

func TestTodoUsecase_CreateTodo(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	tests := []struct {
		name    string
		req     *models.CreateTodoRequest
		wantErr error
	}{
		{
			name: "Valid todo creation",
			req: &models.CreateTodoRequest{
				Title:       "Test Todo",
				Description: "Test Description",
			},
			wantErr: nil,
		},
		{
			name: "Valid todo with priority",
			req: &models.CreateTodoRequest{
				Title:       "High Priority Todo",
				Description: "Important task",
				Priority:    "high",
			},
			wantErr: nil,
		},
		{
			name: "Todo with default priority",
			req: &models.CreateTodoRequest{
				Title:       "Default Priority Todo",
				Description: "Normal task",
			},
			wantErr: nil,
		},
		{
			name: "Invalid priority should fail",
			req: &models.CreateTodoRequest{
				Title:       "Invalid Priority",
				Description: "Test Description",
				Priority:    "invalid",
			},
			wantErr: usecase.ErrInvalidInput,
		},
		{
			name: "Empty title should fail",
			req: &models.CreateTodoRequest{
				Title:       "",
				Description: "Test Description",
			},
			wantErr: usecase.ErrInvalidInput,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// No need to truncate tables - each test runs in its own transaction

			todo, err := todoUsecase.CreateTodo(tt.req)

			if tt.wantErr != nil {
				assert.ErrorIs(t, err, tt.wantErr)
				assert.Nil(t, todo)
			} else {
				require.NoError(t, err)
				assert.NotNil(t, todo)
				assert.NotZero(t, todo.ID)
				assert.Equal(t, tt.req.Title, todo.Title)
				assert.Equal(t, tt.req.Description, todo.Description)
				assert.False(t, todo.Completed)
				
				// Check priority
				if tt.req.Priority != "" {
					assert.Equal(t, tt.req.Priority, todo.Priority)
				} else {
					assert.Equal(t, "medium", todo.Priority) // Default priority
				}
			}
		})
	}
}

func TestTodoUsecase_GetTodoByID(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Create a test todo first
	createdTodo, err := todoUsecase.CreateTodo(&models.CreateTodoRequest{
		Title:       "Test Todo",
		Description: "Test Description",
	})
	require.NoError(t, err)

	tests := []struct {
		name    string
		id      int
		wantErr error
	}{
		{
			name:    "Valid ID",
			id:      createdTodo.ID,
			wantErr: nil,
		},
		{
			name:    "Non-existent ID",
			id:      9999,
			wantErr: usecase.ErrTodoNotFound,
		},
		{
			name:    "Invalid ID (zero)",
			id:      0,
			wantErr: usecase.ErrInvalidInput,
		},
		{
			name:    "Invalid ID (negative)",
			id:      -1,
			wantErr: usecase.ErrInvalidInput,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			todo, err := todoUsecase.GetTodoByID(tt.id)

			if tt.wantErr != nil {
				assert.ErrorIs(t, err, tt.wantErr)
				assert.Nil(t, todo)
			} else {
				require.NoError(t, err)
				assert.NotNil(t, todo)
				assert.Equal(t, createdTodo.ID, todo.ID)
				assert.Equal(t, createdTodo.Title, todo.Title)
			}
		})
	}
}

func TestTodoUsecase_GetAllTodos(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Test empty list
	todos, err := todoUsecase.GetAllTodos()
	require.NoError(t, err)
	assert.Empty(t, todos)

	// Create some todos
	for i := 1; i <= 3; i++ {
		_, err := todoUsecase.CreateTodo(&models.CreateTodoRequest{
			Title:       fmt.Sprintf("Todo %d", i),
			Description: fmt.Sprintf("Description %d", i),
		})
		require.NoError(t, err)
	}

	// Test with todos
	todos, err = todoUsecase.GetAllTodos()
	require.NoError(t, err)
	assert.Len(t, todos, 3)

	// Verify that all todos are present (order may vary due to same timestamp)
	todoTitles := make([]string, len(todos))
	for i, todo := range todos {
		todoTitles[i] = todo.Title
	}

	// Check that all expected titles are present
	assert.Contains(t, todoTitles, "Todo 1")
	assert.Contains(t, todoTitles, "Todo 2")
	assert.Contains(t, todoTitles, "Todo 3")

	// Verify that todos are sorted by created_at DESC (newest first)
	// Since they might have the same timestamp, we'll just verify the structure
	for i := 0; i < len(todos)-1; i++ {
		assert.GreaterOrEqual(t, todos[i].CreatedAt.Unix(), todos[i+1].CreatedAt.Unix())
	}
}

func TestTodoUsecase_UpdateTodo(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Create a test todo first
	createdTodo, err := todoUsecase.CreateTodo(&models.CreateTodoRequest{
		Title:       "Original Title",
		Description: "Original Description",
	})
	require.NoError(t, err)

	completedTrue := true
	completedFalse := false

	tests := []struct {
		name    string
		id      int
		req     *models.UpdateTodoRequest
		wantErr error
	}{
		{
			name: "Update title only",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Title: "Updated Title",
			},
			wantErr: nil,
		},
		{
			name: "Update description only",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Description: "Updated Description",
			},
			wantErr: nil,
		},
		{
			name: "Update completed status",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Completed: &completedTrue,
			},
			wantErr: nil,
		},
		{
			name: "Update priority only",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Priority: "high",
			},
			wantErr: nil,
		},
		{
			name: "Invalid priority should fail",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Priority: "invalid",
			},
			wantErr: usecase.ErrInvalidInput,
		},
		{
			name: "Update all fields",
			id:   createdTodo.ID,
			req: &models.UpdateTodoRequest{
				Title:       "Fully Updated Title",
				Description: "Fully Updated Description",
				Completed:   &completedFalse,
				Priority:    "low",
			},
			wantErr: nil,
		},
		{
			name: "Non-existent ID",
			id:   9999,
			req: &models.UpdateTodoRequest{
				Title: "Should Fail",
			},
			wantErr: usecase.ErrTodoNotFound,
		},
		{
			name: "Invalid ID",
			id:   0,
			req: &models.UpdateTodoRequest{
				Title: "Should Fail",
			},
			wantErr: usecase.ErrInvalidInput,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			todo, err := todoUsecase.UpdateTodo(tt.id, tt.req)

			if tt.wantErr != nil {
				assert.ErrorIs(t, err, tt.wantErr)
				assert.Nil(t, todo)
			} else {
				require.NoError(t, err)
				assert.NotNil(t, todo)

				if tt.req.Title != "" {
					assert.Equal(t, tt.req.Title, todo.Title)
				}
				if tt.req.Description != "" {
					assert.Equal(t, tt.req.Description, todo.Description)
				}
				if tt.req.Completed != nil {
					assert.Equal(t, *tt.req.Completed, todo.Completed)
				}
				if tt.req.Priority != "" {
					assert.Equal(t, tt.req.Priority, todo.Priority)
				}
			}
		})
	}
}

func TestTodoUsecase_DeleteTodo(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Create a test todo first
	createdTodo, err := todoUsecase.CreateTodo(&models.CreateTodoRequest{
		Title:       "To Be Deleted",
		Description: "This will be deleted",
	})
	require.NoError(t, err)

	tests := []struct {
		name    string
		id      int
		wantErr error
	}{
		{
			name:    "Valid deletion",
			id:      createdTodo.ID,
			wantErr: nil,
		},
		{
			name:    "Non-existent ID",
			id:      9999,
			wantErr: usecase.ErrTodoNotFound,
		},
		{
			name:    "Invalid ID",
			id:      0,
			wantErr: usecase.ErrInvalidInput,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := todoUsecase.DeleteTodo(tt.id)

			if tt.wantErr != nil {
				assert.ErrorIs(t, err, tt.wantErr)
			} else {
				require.NoError(t, err)

				// Verify deletion
				_, err := todoUsecase.GetTodoByID(tt.id)
				assert.ErrorIs(t, err, usecase.ErrTodoNotFound)
			}
		})
	}
}

func TestTodoUsecase_PriorityFeature(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Test creating todos with different priorities
	priorities := []string{"low", "medium", "high"}
	createdTodos := make([]*models.Todo, len(priorities))

	for i, priority := range priorities {
		todo, err := todoUsecase.CreateTodo(&models.CreateTodoRequest{
			Title:       fmt.Sprintf("Todo with %s priority", priority),
			Description: fmt.Sprintf("Testing %s priority", priority),
			Priority:    priority,
		})
		require.NoError(t, err)
		assert.Equal(t, priority, todo.Priority)
		createdTodos[i] = todo
	}

	// Test updating priority
	updatedTodo, err := todoUsecase.UpdateTodo(createdTodos[0].ID, &models.UpdateTodoRequest{
		Priority: "high",
	})
	require.NoError(t, err)
	assert.Equal(t, "high", updatedTodo.Priority)
	assert.Equal(t, createdTodos[0].Title, updatedTodo.Title) // Other fields should remain unchanged

	// Test GetAll returns todos with priority
	allTodos, err := todoUsecase.GetAllTodos()
	require.NoError(t, err)
	assert.Len(t, allTodos, len(priorities))

	// Verify all todos have priority field
	for _, todo := range allTodos {
		assert.NotEmpty(t, todo.Priority)
		assert.Contains(t, []string{"low", "medium", "high"}, todo.Priority)
	}

	// Test GetByID returns todo with priority
	retrievedTodo, err := todoUsecase.GetTodoByID(createdTodos[1].ID)
	require.NoError(t, err)
	assert.Equal(t, "medium", retrievedTodo.Priority)
}
