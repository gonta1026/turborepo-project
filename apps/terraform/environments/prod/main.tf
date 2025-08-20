# ======================================
# Prod Environment - Module-based Configuration
# ======================================
# modules/を使用したモジュール構成

# ======================================
# Local Values
# ======================================

locals {
  common_labels = {
    team       = "platform"
    managed_by = "terraform"
  }
}

# ======================================
# Shared Module
# ======================================

module "shared" {
  source = "../../modules/shared"

  project_id        = var.project_id
  region            = var.region
  labels            = local.common_labels
  dev_team_group    = var.dev_team_group
  github_repository = var.github_repository
}


# ======================================
# Dashboard Module
# ======================================

module "dashboard" {
  source     = "../../modules/dashboard"
  depends_on = [module.shared]

  project_id = var.project_id
  region     = var.region
  labels     = local.common_labels

  # Bucket configuration
  bucket_name          = var.bucket_name
  force_destroy_bucket = false # 本番環境は保護

  # Domain configuration
  domain_name = var.domain_name

  # Certificate dependencies from shared module
  shared_certificate_map_name = module.shared.shared_certificate_map_name
  shared_certificate_map_id   = module.shared.shared_certificate_map_id

  # CDN configuration (prod環境用)
  enable_cdn            = true
  cdn_cache_mode        = "CACHE_ALL_STATIC"
  cdn_default_ttl       = 7200 # 本番環境は長めのキャッシュ
  cdn_client_ttl        = 14400
  cdn_max_ttl           = 21600
  cdn_negative_caching  = true
  cdn_serve_while_stale = 172800 # 本番環境は長めのStale対応
}

# ======================================
# API Module
# ======================================

module "api" {
  source     = "../../modules/api"
  depends_on = [module.shared]

  project_id = var.project_id
  region     = var.region
  labels     = local.common_labels

  # Network dependencies from shared module
  vpc_connector_id       = module.shared.vpc_connector_id
  api_static_ip_address  = module.shared.api_static_ip_address
  vpc_network_id         = module.shared.vpc_network_id
  private_vpc_connection = module.shared.private_vpc_connection

  # Certificate dependencies from shared module
  shared_certificate_map_name = module.shared.shared_certificate_map_name
  shared_certificate_map_id   = module.shared.shared_certificate_map_id

  # Database configuration (prod環境用の設定)
  database_name        = var.database_name
  database_user        = var.database_user
  db_tier              = "db-standard-1" # 本番環境は高性能
  db_availability_type = "REGIONAL"      # 本番環境は冗長化
  db_disk_size         = 100             # 本番環境は大容量
  deletion_protection  = true            # 本番環境は削除保護

  # Domain configuration
  api_domain_name      = var.api_domain_name
  cors_allowed_origins = var.dashboard_client_url

  # Cloud Run configuration (prod環境用)
  container_port     = 8080
  cpu_limit          = "2000m" # 本番環境は高性能
  memory_limit       = "2Gi"   # 本番環境は大容量
  startup_cpu_boost  = true
  min_instance_count = 2  # 本番環境は常時稼働
  max_instance_count = 20 # 本番環境は高スケール

  # Health check configuration
  health_check_path                = "/health"
  startup_probe_initial_delay      = 15 # 本番環境は余裕を持った設定
  startup_probe_period             = 10
  startup_probe_timeout            = 10
  startup_probe_failure_threshold  = 5
  liveness_probe_period            = 60 # 本番環境は長めの間隔
  liveness_probe_timeout           = 10
  liveness_probe_failure_threshold = 5

  # Load balancer configuration
  enable_backend_logging = true
}
