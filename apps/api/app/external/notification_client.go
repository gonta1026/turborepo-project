package external

import (
	"context"
)

// NotificationRequest は通知送信のリクエスト構造体
type NotificationRequest struct {
	UserID  int    `json:"user_id"`
	Title   string `json:"title"`
	Message string `json:"message"`
	Type    string `json:"type"` // "email", "push", "sms"
}

// NotificationResponse は通知送信のレスポンス構造体
type NotificationResponse struct {
	NotificationID string `json:"notification_id"`
	Status         string `json:"status"`
	SentAt         string `json:"sent_at"`
}

// NotificationClient は外部通知サービスとの通信を行うインターフェース
type NotificationClient interface {
	// SendNotification は通知を送信する
	SendNotification(ctx context.Context, req *NotificationRequest) (*NotificationResponse, error)
	
	// GetNotificationStatus は通知の配信状況を確認する
	GetNotificationStatus(ctx context.Context, notificationID string) (string, error)
	
	// BatchSendNotifications は複数の通知を一括送信する
	BatchSendNotifications(ctx context.Context, reqs []*NotificationRequest) ([]*NotificationResponse, error)
}