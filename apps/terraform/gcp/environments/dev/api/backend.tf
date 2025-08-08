terraform {
  backend "gcs" {
    bucket = "terraform-gcp-466623-terraform-state"
    prefix = "dev/api"
  }
}