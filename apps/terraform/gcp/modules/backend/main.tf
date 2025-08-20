# ======================================
# Backend Module
# ======================================
# Terraform State管理、データベース等のバックエンドリソースを管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project     = var.project_id
    environment = var.environment
    managed_by  = "terraform"
    module      = "backend"
  })
}

# ======================================
# Random Resources
# ======================================

resource "random_password" "api_database_password" {
  length  = 32
  special = true
}

# ======================================
# Terraform State用GCSバケット
# ======================================

resource "google_storage_bucket" "terraform_state" {
  name          = "terraform-gcp-466623-terraform-state"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  labels = local.common_labels
}

# ======================================
# API Database用Secret
# ======================================

resource "google_secret_manager_secret" "api_database_password" {
  secret_id = "api-database-password"

  labels = local.common_labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_database_password" {
  secret      = google_secret_manager_secret.api_database_password.id
  secret_data = random_password.api_database_password.result
}

# ======================================
# API Cloud SQLインスタンス
# ======================================

resource "google_sql_database_instance" "api_db_instance" {
  name             = "${var.project_id}-api-db-${var.environment}"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_type         = "PD_SSD"
    disk_size         = var.db_disk_size

    backup_configuration {
      enabled                        = true
      start_time                     = "04:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
      require_ssl     = true
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [var.private_vpc_connection]
}

# ======================================
# API データベース
# ======================================

resource "google_sql_database" "api_database" {
  name      = var.database_name
  instance  = google_sql_database_instance.api_db_instance.name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

# ======================================
# API データベースユーザー
# ======================================

resource "google_sql_user" "api_user" {
  name     = var.database_user
  instance = google_sql_database_instance.api_db_instance.name
  password = random_password.api_database_password.result
}