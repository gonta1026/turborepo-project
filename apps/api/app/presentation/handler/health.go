package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type HealthHandler struct{}

type HealthResponse struct {
	Status  string `json:"status" example:"healthy" validate:"required"`
	Message string `json:"message" example:"API server is running" validate:"required"`
}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

// HealthCheck handles health check endpoint
// @Summary Health check endpoint
// @Description Check if the API server is running
// @Tags health
// @Accept json
// @Produce json
// @Success 200 {object} HealthResponse{status=string,message=string}
// @Router /health [get]
func (h *HealthHandler) HealthCheck(c *gin.Context) {
	response := HealthResponse{
		Status:  "healthy",
		Message: "API server is running",
	}
	c.JSON(http.StatusOK, response)
}