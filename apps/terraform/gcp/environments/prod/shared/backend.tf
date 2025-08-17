terraform {
  backend "gcs" {
    bucket = "terraform-gcp-prod-468022-terraform-state"
    prefix = "prod/shared"
  }
}