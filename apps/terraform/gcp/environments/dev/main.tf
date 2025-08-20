# ======================================
# Dev Environment - Module-based Configuration
# ======================================
# modules/を使用したモジュール構成

# ======================================
# Local Values
# ======================================

locals {
  environment = "dev"
  
  common_labels = {
    environment = local.environment
    team        = "platform"
    managed_by  = "terraform"
  }
}

# ======================================
# Shared Module
# ======================================

module "shared" {
  source = "../../modules/shared"
  
  project_id        = var.project_id
  region            = var.region
  environment       = local.environment
  labels            = local.common_labels
  dev_team_group    = var.dev_team_group
  github_repository = var.github_repository
}

# ======================================
# Backend Module
# ======================================

module "backend" {
  source = "../../modules/backend"
  depends_on = [module.shared]
  
  project_id             = var.project_id
  region                 = var.region
  environment           = local.environment
  labels                = local.common_labels
  
  # Network dependencies from shared module
  vpc_network_id        = module.shared.vpc_network_id
  private_vpc_connection = module.shared.private_vpc_connection
  
  # Database configuration (dev環境用の設定)
  database_name         = var.database_name
  database_user         = var.database_user
  db_tier              = "db-f1-micro"  # 開発環境は低コスト
  db_availability_type = "ZONAL"        # 開発環境は単一ゾーン
  db_disk_size         = 10
  deletion_protection  = false          # 開発環境は削除を許可
}

# ======================================
# Dashboard Module
# ======================================

module "dashboard" {
  source = "../../modules/dashboard"
  depends_on = [module.shared]
  
  project_id   = var.project_id
  region       = var.region
  environment  = local.environment
  labels       = local.common_labels
  
  # Bucket configuration
  bucket_name           = var.bucket_name
  force_destroy_bucket  = true  # 開発環境は強制削除を許可
  
  # Domain configuration
  domain_name = var.domain_name
  
  # Certificate dependencies from shared module
  shared_certificate_map_name = module.shared.shared_certificate_map_name
  shared_certificate_map_id   = module.shared.shared_certificate_map_id
  
  # CDN configuration (dev環境用)
  enable_cdn            = true
  cdn_cache_mode        = "CACHE_ALL_STATIC"
  cdn_default_ttl       = 3600
  cdn_client_ttl        = 7200
  cdn_max_ttl           = 10800
  cdn_negative_caching  = true
  cdn_serve_while_stale = 86400
}

# ======================================
# API Module
# ======================================

module "api" {
  source = "../../modules/api"
  depends_on = [module.shared, module.backend]
  
  project_id   = var.project_id
  region       = var.region
  environment  = local.environment
  labels       = local.common_labels
  
  # Network dependencies from shared module
  vpc_connector_id      = module.shared.vpc_connector_id
  api_static_ip_address = module.shared.api_static_ip_address
  
  # Certificate dependencies from shared module
  shared_certificate_map_name = module.shared.shared_certificate_map_name
  shared_certificate_map_id   = module.shared.shared_certificate_map_id
  
  # Database dependencies from backend module
  database_connection_info = module.backend.database_connection_info
  
  # Domain configuration
  api_domain_name      = var.api_domain_name
  cors_allowed_origins = var.dashboard_client_url
  
  # Cloud Run configuration (dev環境用)
  container_port       = 8080
  cpu_limit           = "1000m"     # 開発環境はミディアム
  memory_limit        = "512Mi"     # 開発環境はミディアム
  startup_cpu_boost   = true
  min_instance_count  = 0           # 開発環境はコスト削減
  max_instance_count  = 5           # 開発環境は制限
  
  # Health check configuration
  health_check_path                = "/health"
  startup_probe_initial_delay      = 10
  startup_probe_period             = 10
  startup_probe_timeout            = 5
  startup_probe_failure_threshold  = 3
  liveness_probe_period            = 30
  liveness_probe_timeout           = 5
  liveness_probe_failure_threshold = 3
  
  # Load balancer configuration
  enable_backend_logging = true
}