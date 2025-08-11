package config

import (
	"fmt"

	"github.com/kelseyhightower/envconfig"
)

type Config struct {
	DBHost     string `envconfig:"DB_HOST" required:"true"`
	DBPort     string `envconfig:"DB_PORT" required:"true"`
	DBUser     string `envconfig:"DB_USER" required:"true"`
	DBPassword string `envconfig:"DB_PASSWORD" required:"true"`
	DBName     string `envconfig:"DB_NAME" required:"true"`
	DBSSLMode  string `envconfig:"DB_SSLMODE" default:"disable"`
	
	// Cloud SQL specific
	UseCloudSQL      bool   `envconfig:"USE_CLOUD_SQL" default:"false"`
	CloudSQLInstance string `envconfig:"CLOUD_SQL_INSTANCE" default:""`
	
	// Environment
	Environment string `envconfig:"ENVIRONMENT" default:"development"`
}

func Load() (*Config, error) {
	var config Config
	err := envconfig.Process("", &config)
	if err != nil {
		return nil, fmt.Errorf("failed to load config: %w", err)
	}
	
	return &config, nil
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

