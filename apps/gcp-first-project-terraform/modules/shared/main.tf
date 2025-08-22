# ======================================
# Shared Resources Module
# ======================================
# VPC、IAM、基盤リソースを管理

# ======================================
# Local Values
# ======================================

locals {
  common_labels = merge(var.labels, {
    project    = var.project_id
    managed_by = "terraform"
  })

  network_name = "${var.project_id}-vpc"

  public_subnet_cidr     = "10.0.1.0/24"
  private_subnet_cidr    = "10.0.2.0/24"
  management_subnet_cidr = "10.0.3.0/24"
  vpc_connector_cidr     = "10.8.0.0/28"
}

# ======================================
# API有効化
# ======================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudapis.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "container_apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project_service.required_apis]
}

resource "google_project_service" "network_apis" {
  for_each = toset([
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project_service.required_apis]
}

resource "google_project_service" "database_apis" {
  for_each = toset([
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project_service.required_apis]
}

resource "google_project_service" "load_balancer_apis" {
  for_each = toset([
    "certificatemanager.googleapis.com",
    "dns.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project_service.required_apis]
}

resource "google_project_service" "secret_manager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project_service.required_apis]
}

# ======================================
# IAMカスタムロール
# ======================================

resource "google_project_iam_custom_role" "cache_invalidator" {
  role_id     = "cacheInvalidator"
  title       = "Cache Invalidator"
  description = "Can invalidate CDN cache"
  permissions = [
    "compute.urlMaps.invalidateCache"
  ]

  depends_on = [google_project_service.required_apis]
}

# ======================================
# サービスアカウント
# ======================================

resource "google_service_account" "github_actions_deployer" {
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer"
  description  = "Service account for GitHub Actions deployment"

  depends_on = [google_project_service.required_apis]
}

resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions_deployer.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "github_actions_permissions" {
  for_each = toset([
    "roles/storage.admin",
    "roles/run.admin",
    "roles/cloudbuild.builds.editor",
    "roles/artifactregistry.admin",
    "roles/sql.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/certificatemanager.editor",
    "roles/dns.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"

  depends_on = [google_service_account.github_actions_deployer]
}

resource "google_project_iam_member" "github_actions_cache_invalidator" {
  project = var.project_id
  role    = google_project_iam_custom_role.cache_invalidator.name
  member  = "serviceAccount:${google_service_account.github_actions_deployer.email}"
}

resource "google_project_iam_member" "dev_team_permissions" {
  for_each = toset([
    "roles/editor",
    "roles/storage.admin",
    "roles/run.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "group:${var.dev_team_group}"

  depends_on = [google_project_service.required_apis]
}

# ======================================
# Workload Identity Federation
# ======================================

resource "google_iam_workload_identity_pool" "github_actions_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"

  depends_on = [google_project_service.required_apis]
}

resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.github_actions_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_pool.name}/attribute.repository/${var.github_repository}"
}

# ======================================
# VPCネットワーク
# ======================================

resource "google_compute_network" "main_vpc" {
  name                    = local.network_name
  auto_create_subnetworks = false
  mtu                     = 1460

  depends_on = [google_project_service.network_apis]
}

# ======================================
# サブネット
# ======================================

resource "google_compute_subnetwork" "public_subnet" {
  name          = "${local.network_name}-public"
  ip_cidr_range = local.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.main_vpc.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "${local.network_name}-private"
  ip_cidr_range = local.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.main_vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "management_subnet" {
  name          = "${local.network_name}-management"
  ip_cidr_range = local.management_subnet_cidr
  region        = var.region
  network       = google_compute_network.main_vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ======================================
# Private Service Connection
# ======================================

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main_vpc.id

  depends_on = [google_project_service.database_apis]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# ======================================
# Cloud Router & NAT
# ======================================

resource "google_compute_router" "main_router" {
  name    = "${local.network_name}-router"
  region  = var.region
  network = google_compute_network.main_vpc.id
}

resource "google_compute_router_nat" "main_nat" {
  name   = "${local.network_name}-nat"
  router = google_compute_router.main_router.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.management_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ======================================
# VPC Access Connector
# ======================================

resource "google_vpc_access_connector" "main_connector" {
  name          = "main-vpc-connector"
  region        = var.region
  ip_cidr_range = local.vpc_connector_cidr
  network       = google_compute_network.main_vpc.name

  min_throughput = 200
  max_throughput = 300

  depends_on = [google_project_service.network_apis]
}

# ======================================
# ファイアウォールルール
# ======================================

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    local.public_subnet_cidr,
    local.private_subnet_cidr,
    local.management_subnet_cidr
  ]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh-allowed"]
}

# ======================================
# 静的IPアドレス
# ======================================

resource "google_compute_global_address" "api_ip" {
  name = "api-static-ip"
}

# ======================================
# Certificate Manager
# ======================================

resource "google_certificate_manager_certificate_map" "shared_cert_map" {
  name        = "shared-cert-map"
  description = "Shared certificate map for all services"

  labels = local.common_labels

  depends_on = [google_project_service.load_balancer_apis]
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

  depends_on = [google_project_service.required_apis]
}

# ======================================
# Artifact Registry
# ======================================

resource "google_artifact_registry_repository" "api_service" {
  location      = var.region
  repository_id = "api-service"
  description   = "Docker repository for API service"
  format        = "DOCKER"

  labels = local.common_labels

  depends_on = [google_project_service.container_apis]
}

resource "google_artifact_registry_repository" "dashboard_service" {
  location      = var.region
  repository_id = "dashboard-service"
  description   = "Docker repository for Dashboard service"
  format        = "DOCKER"

  labels = local.common_labels

  depends_on = [google_project_service.container_apis]
}