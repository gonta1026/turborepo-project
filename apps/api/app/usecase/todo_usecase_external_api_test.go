package usecase_test

import (
	"api/app/external"
	extMock "api/app/external/mock"
	"api/app/models"
	"api/app/usecase"
	"api/repository"
	"api/test"
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTodoUsecase_CreateTodo_WithExternalAPI_Mock(t *testing.T) {
	// 実DBセットアップ（Repository部分は実データベース使用）
	db, cleanup := test.SetupTestDB()
	defer cleanup()
	
	// 実Repository作成
	todoRepo := repository.NewTodoRepository(db)
	
	// Mock外部APIクライアント作成
	mockNotificationClient := extMock.NewMockNotificationClient(t)
	
	// UseCase作成（Repository=実DB, 外部API=Mock）
	todoUsecase := usecase.NewTodoUsecase(todoRepo, mockNotificationClient)

	// テストデータ
	todo := &models.Todo{
		Title:       "外部API統合テスト",
		Description: "Mock通知送信のテスト",
		Priority:    "high",
		Completed:   false,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	// Mock外部APIの期待値設定
	expectedNotificationReq := &external.NotificationRequest{
		UserID:  1,
		Title:   "新しいTodoが作成されました",
		Message: "「外部API統合テスト」が作成されました。優先度: high",
		Type:    "push",
	}
	
	expectedNotificationResp := &external.NotificationResponse{
		NotificationID: "notif-12345",
		Status:         "sent",
		SentAt:         "2025-09-07T15:00:00Z",
	}

	// 外部API呼び出しのMock設定
	mockNotificationClient.EXPECT().
		SendNotification(context.Background(), expectedNotificationReq).
		Return(expectedNotificationResp, nil).
		Once()

	// テスト実行
	result, err := todoUsecase.CreateTodo(todo)

	// 結果検証
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.NotZero(t, result.ID) // DB に実際に保存されたID
	assert.Equal(t, "外部API統合テスト", result.Title)
	assert.Equal(t, "Mock通知送信のテスト", result.Description)
	assert.Equal(t, "high", result.Priority)
	assert.False(t, result.Completed)
	
	// 実DBに保存されていることを確認
	savedTodo, err := todoRepo.GetByID(result.ID)
	require.NoError(t, err)
	assert.NotNil(t, savedTodo)
	assert.Equal(t, "外部API統合テスト", savedTodo.Title)
	
	// Mockの期待値が満たされたことを自動検証（testifyが自動で行う）
}

func TestTodoUsecase_CreateTodo_WithExternalAPI_Error(t *testing.T) {
	// 実DBセットアップ
	db, cleanup := test.SetupTestDB()
	defer cleanup()
	
	// 実Repository作成
	todoRepo := repository.NewTodoRepository(db)
	
	// Mock外部APIクライアント作成
	mockNotificationClient := extMock.NewMockNotificationClient(t)
	
	// UseCase作成
	todoUsecase := usecase.NewTodoUsecase(todoRepo, mockNotificationClient)

	// テストデータ
	todo := &models.Todo{
		Title:       "通知エラーテスト",
		Description: "外部APIエラーのテスト",
		Priority:    "medium",
		Completed:   false,
	}

	// Mock外部APIの期待値設定（エラーを返す）
	expectedNotificationReq := &external.NotificationRequest{
		UserID:  1,
		Title:   "新しいTodoが作成されました",
		Message: "「通知エラーテスト」が作成されました。優先度: medium",
		Type:    "push",
	}

	// 外部APIが失敗する場合のMock設定
	mockNotificationClient.EXPECT().
		SendNotification(context.Background(), expectedNotificationReq).
		Return(nil, assert.AnError). // エラーを返す
		Once()

	// テスト実行
	result, err := todoUsecase.CreateTodo(todo)

	// 結果検証：外部APIが失敗してもTodo作成は成功する
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "通知エラーテスト", result.Title)
	
	// DBには正常に保存されていることを確認
	savedTodo, err := todoRepo.GetByID(result.ID)
	require.NoError(t, err)
	assert.NotNil(t, savedTodo)
	assert.Equal(t, "通知エラーテスト", savedTodo.Title)
}