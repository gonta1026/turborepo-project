package config

import (
	"fmt"
	"os"
)

type Config struct {
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string
	
	// Cloud SQL specific
	UseCloudSQL      bool
	CloudSQLInstance string
	
	// Environment
	Environment string
}

func Load() *Config {
	return &Config{
		DBHost:           getEnv("DB_HOST", "localhost"),
		DBPort:           getEnv("DB_PORT", "9000"),
		DBUser:           getEnv("DB_USER", "apiuser"),
		DBPassword:       getEnv("DB_PASSWORD", "apipassword"),
		DBName:           getEnv("DB_NAME", "apidb"),
		DBSSLMode:        getEnv("DB_SSLMODE", "disable"),
		UseCloudSQL:      getEnvBool("USE_CLOUD_SQL", false),
		CloudSQLInstance: getEnv("CLOUD_SQL_INSTANCE", ""),
		Environment:      getEnv("ENVIRONMENT", "development"),
	}
}

func (c *Config) GetDSN() string {
	if c.UseCloudSQL {
		// Cloud SQL接続用のDSN
		return fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=%s",
			c.CloudSQLInstance,
			c.DBUser,
			c.DBPassword,
			c.DBName,
			c.DBSSLMode,
		)
	}
	
	// 通常のPostgreSQL接続用のDSN
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.DBHost,
		c.DBPort,
		c.DBUser,
		c.DBPassword,
		c.DBName,
		c.DBSSLMode,
	)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
	value := os.Getenv(key)
	if value == "true" || value == "1" {
		return true
	}
	if value == "false" || value == "0" {
		return false
	}
	return defaultValue
}