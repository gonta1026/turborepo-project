package usecase_test

import (
	"api/app/external"
	"api/app/models"
	"api/app/usecase"
	"api/repository"
	"api/test"
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
	// 統合テストなので外部APIも実際のHTTPクライアント使用（ただし設定はテスト用）
	notificationClient := external.NewHTTPNotificationClient("http://localhost:9999", "test-key")
	todoUsecase := usecase.NewTodoUsecase(todoRepo, notificationClient)

	return todoUsecase, cleanup
}

func TestTodoUsecase_CreateTodo(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	tests := []struct {
		name    string
		req     *models.Todo
		wantErr error
	}{
		{
			name: "Valid todo creation",
			req: &models.Todo{
				Title:       "Test Todo",
				Description: "Test Description",
				Priority:    "medium",
			},
			wantErr: nil,
		},
		{
			name: "Valid todo with priority",
			req: &models.Todo{
				Title:       "High Priority Todo",
				Description: "Important task",
				Priority:    "high",
			},
			wantErr: nil,
		},
		{
			name: "Todo with default priority",
			req: &models.Todo{
				Title:       "Default Priority Todo",
				Description: "Normal task",
				Priority:    "medium",
			},
			wantErr: nil,
		},
		{
			name: "Invalid priority should fail",
			req: &models.Todo{
				Title:       "Invalid Priority",
				Description: "Test Description",
				Priority:    "invalid",
			},
			wantErr: usecase.ErrInvalidInput,
		},
		{
			name: "Empty title should fail",
			req: &models.Todo{
				Title:       "",
				Description: "Test Description",
				Priority:    "medium",
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
				assert.Equal(t, tt.req.Priority, todo.Priority)
			}
		})
	}
}

func TestTodoUsecase_GetTodoByID(t *testing.T) {
	todoUsecase, cleanup := setupTest(t)
	defer cleanup()

	// Create a test todo first
	createdTodo, err := todoUsecase.CreateTodo(&models.Todo{
		Title:       "Test Todo",
		Description: "Test Description",
		Priority:    "medium",
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
		_, err := todoUsecase.CreateTodo(&models.Todo{
			Title:       fmt.Sprintf("Todo %d", i),
			Description: fmt.Sprintf("Description %d", i),
			Priority:    "medium",
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
	createdTodo, err := todoUsecase.CreateTodo(&models.Todo{
		Title:       "Original Title",
		Description: "Original Description",
		Priority:    "medium",
	})
	require.NoError(t, err)

	completedTrue := true
	completedFalse := false

	tests := []struct {
		name    string
		id      int
		req     *models.Todo
		wantErr error
	}{
		{
			name: "Update title only",
			id:   createdTodo.ID,
			req: &models.Todo{
				Title: "Updated Title",
			},
			wantErr: nil,
		},
		{
			name: "Update description only",
			id:   createdTodo.ID,
			req: &models.Todo{
				Description: "Updated Description",
			},
			wantErr: nil,
		},
		{
			name: "Update completed status",
			id:   createdTodo.ID,
			req: &models.Todo{
				Completed: completedTrue,
			},
			wantErr: nil,
		},
		{
			name: "Update priority only",
			id:   createdTodo.ID,
			req: &models.Todo{
				Priority: "high",
			},
			wantErr: nil,
		},
		{
			name: "Invalid priority should fail",
			id:   createdTodo.ID,
			req: &models.Todo{
				Priority: "invalid",
			},
			wantErr: usecase.ErrInvalidInput,
		},
		{
			name: "Update all fields",
			id:   createdTodo.ID,
			req: &models.Todo{
				Title:       "Fully Updated Title",
				Description: "Fully Updated Description",
				Completed:   completedFalse,
				Priority:    "low",
			},
			wantErr: nil,
		},
		{
			name: "Non-existent ID",
			id:   9999,
			req: &models.Todo{
				Title: "Should Fail",
			},
			wantErr: usecase.ErrTodoNotFound,
		},
		{
			name: "Invalid ID",
			id:   0,
			req: &models.Todo{
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
	createdTodo, err := todoUsecase.CreateTodo(&models.Todo{
		Title:       "To Be Deleted",
		Description: "This will be deleted",
		Priority:    "medium",
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
	priorities := []models.TodoPriority{models.PriorityLow, models.PriorityMedium, models.PriorityHigh}
	createdTodos := make([]*models.Todo, len(priorities))

	for i, priority := range priorities {
		todo, err := todoUsecase.CreateTodo(&models.Todo{
			Title:       fmt.Sprintf("Todo with %s priority", priority),
			Description: fmt.Sprintf("Testing %s priority", priority),
			Priority:    priority,
		})
		require.NoError(t, err)
		assert.Equal(t, priority, todo.Priority)
		createdTodos[i] = todo
	}

	// Test updating priority
	updatedTodo, err := todoUsecase.UpdateTodo(createdTodos[0].ID, &models.Todo{
		Priority: models.PriorityHigh,
	})
	require.NoError(t, err)
	assert.Equal(t, models.PriorityHigh, updatedTodo.Priority)
	assert.Equal(t, createdTodos[0].Title, updatedTodo.Title) // Other fields should remain unchanged

	// Test GetAll returns todos with priority
	allTodos, err := todoUsecase.GetAllTodos()
	require.NoError(t, err)
	assert.Len(t, allTodos, len(priorities))

	// Verify all todos have priority field
	for _, todo := range allTodos {
		assert.NotEmpty(t, todo.Priority)
		assert.Contains(t, []models.TodoPriority{models.PriorityLow, models.PriorityMedium, models.PriorityHigh}, todo.Priority)
	}

	// Test GetByID returns todo with priority
	retrievedTodo, err := todoUsecase.GetTodoByID(createdTodos[1].ID)
	require.NoError(t, err)
	assert.Equal(t, models.PriorityMedium, retrievedTodo.Priority)
}
