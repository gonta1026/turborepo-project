package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type SimpleHandler struct{}

type APIResponse struct {
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

func NewSimpleHandler() *SimpleHandler {
	return &SimpleHandler{}
}

func (h *SimpleHandler) Hello(c *gin.Context) {
	name := c.DefaultQuery("name", "World")
	response := APIResponse{
		Message: "Hello from Go API!",
		Data:    gin.H{"greeting": "Hello, " + name + "!"},
	}
	c.JSON(http.StatusOK, response)
}

func (h *SimpleHandler) GetUsers(c *gin.Context) {
	users := []gin.H{
		{"id": 1, "name": "John Doe", "email": "john@example.com"},
		{"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
	}
	response := APIResponse{
		Message: "Users retrieved successfully",
		Data:    users,
	}
	c.JSON(http.StatusOK, response)
}

func (h *SimpleHandler) CreateUser(c *gin.Context) {
	var newUser gin.H
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	newUser["id"] = 3
	response := APIResponse{
		Message: "User created successfully",
		Data:    newUser,
	}
	c.JSON(http.StatusCreated, response)
}