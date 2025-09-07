package container

import (
	"api/app/external"
	extMock "api/app/external/mock"
	"api/app/usecase"
	"api/config"
	"api/repository"

	"github.com/jmoiron/sqlx"
)

// Container はアプリケーションの依存性を管理するコンテナ
type Container struct {
	TodoUsecase usecase.TodoUsecase
}

// NewMockContainer はテスト用のMock Containerを作成（外部APIのみMock）
func NewMockContainer(db *sqlx.DB) *Container {
	// Repository は実DB使用
	todoRepo := repository.NewTodoRepository(db)

	// 外部APIクライアントはMock使用
	notificationClient := &extMock.MockNotificationClient{}

	return &Container{
		TodoUsecase: usecase.NewTodoUsecase(todoRepo, notificationClient),
	}
}

// NewContainer は本番用のContainerを作成
func NewContainer(db *sqlx.DB, cfg *config.Config) *Container {
	todoRepo := repository.NewTodoRepository(db)

	// 実 外部APIクライアント使用
	notificationClient := external.NewHTTPNotificationClient(
		cfg.NotificationAPIURL,
		cfg.NotificationAPIKey,
	)

	return &Container{
		TodoUsecase: usecase.NewTodoUsecase(todoRepo, notificationClient),
	}
}
