# GCP Project Configuration - API Service
project_id = "terraform-gcp-466623"

# Region and Zone Configuration - Asia Northeast (Tokyo)
region = "asia-northeast1"
zone   = "asia-northeast1-a"

# Labels for API resources
labels = {
  service    = "api"
  managed_by = "terraform"
}

# API Domain Configuration
api_domain_name = "dev.api.my-learn-iac-sample.site"

# Database Configuration
database_name = "api_db"
database_user = "api_user"

# CORS Configuration
dashboard_client_url = "https://dev.dashboard.my-learn-iac-sample.site"
