package container

import (
	"api/app/external"
	extMock "api/app/external/mock"
	"api/app/presentation/handler"
	"api/app/usecase"
	"api/config"
	"api/repository"

	"github.com/jmoiron/sqlx"
)

// Handlers は全てのハンドラーを管理する構造体
type Handlers struct {
	Health *handler.HealthHandler
	Simple *handler.SimpleHandler
	Todo   *handler.TodoHandler
}

// Infrastructure はインフラストラクチャレイヤーの依存性を管理
type Infrastructure struct {
	DB                 *sqlx.DB
	NotificationClient external.NotificationClient
}

// Domain はドメインレイヤーの依存性を管理
type Domain struct {
	TodoRepository repository.TodoRepository
}

// Application はアプリケーションレイヤーの依存性を管理
type Application struct {
	TodoUsecase usecase.TodoUsecase
}

// NewInfrastructure はインフラストラクチャレイヤーを初期化
func NewInfrastructure(db *sqlx.DB, cfg *config.Config) *Infrastructure {
	var notificationClient external.NotificationClient
	if cfg.UseMock {
		notificationClient = &extMock.MockNotificationClient{}
	} else {
		notificationClient = external.NewHTTPNotificationClient(
			cfg.NotificationAPIURL,
			cfg.NotificationAPIKey,
		)
	}

	return &Infrastructure{
		DB:                 db,
		NotificationClient: notificationClient,
	}
}

// NewDomain はドメインレイヤーを初期化
func NewDomain(infra *Infrastructure) *Domain {
	return &Domain{
		TodoRepository: repository.NewTodoRepository(infra.DB),
	}
}

// NewApplication はアプリケーションレイヤーを初期化
func NewApplication(domain *Domain, infra *Infrastructure) *Application {
	return &Application{
		TodoUsecase: usecase.NewTodoUsecase(domain.TodoRepository, infra.NotificationClient),
	}
}

// InitializeHandlers は全ハンドラーを初期化
func InitializeHandlers(db *sqlx.DB, cfg *config.Config) *Handlers {
	infra := NewInfrastructure(db, cfg)
	domain := NewDomain(infra)
	app := NewApplication(domain, infra)

	return &Handlers{
		Health: handler.NewHealthHandler(),
		Simple: handler.NewSimpleHandler(),
		Todo:   handler.NewTodoHandler(app.TodoUsecase),
	}
}