package external

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// HTTPNotificationClient は実際のHTTP APIを使用する通知クライアント
type HTTPNotificationClient struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

// NewHTTPNotificationClient は新しいHTTP通知クライアントを作成
func NewHTTPNotificationClient(baseURL, apiKey string) NotificationClient {
	return &HTTPNotificationClient{
		baseURL: baseURL,
		apiKey:  apiKey,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// SendNotification は外部APIに通知送信リクエストを送る
func (c *HTTPNotificationClient) SendNotification(ctx context.Context, req *NotificationRequest) (*NotificationResponse, error) {
	url := fmt.Sprintf("%s/notifications", c.baseURL)
	
	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("API request failed with status: %d", resp.StatusCode)
	}

	var notificationResp NotificationResponse
	if err := json.NewDecoder(resp.Body).Decode(&notificationResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &notificationResp, nil
}

// GetNotificationStatus は通知の配信状況を確認
func (c *HTTPNotificationClient) GetNotificationStatus(ctx context.Context, notificationID string) (string, error) {
	url := fmt.Sprintf("%s/notifications/%s/status", c.baseURL, notificationID)
	
	httpReq, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	httpReq.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("API request failed with status: %d", resp.StatusCode)
	}

	var statusResp struct {
		Status string `json:"status"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&statusResp); err != nil {
		return "", fmt.Errorf("failed to decode response: %w", err)
	}

	return statusResp.Status, nil
}

// BatchSendNotifications は複数の通知を一括送信
func (c *HTTPNotificationClient) BatchSendNotifications(ctx context.Context, reqs []*NotificationRequest) ([]*NotificationResponse, error) {
	url := fmt.Sprintf("%s/notifications/batch", c.baseURL)
	
	reqBody := struct {
		Notifications []*NotificationRequest `json:"notifications"`
	}{
		Notifications: reqs,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("API request failed with status: %d", resp.StatusCode)
	}

	var batchResp struct {
		Results []*NotificationResponse `json:"results"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&batchResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return batchResp.Results, nil
}