output "turbo_cache_server_url" {
  description = "Turbo cache server URL"
  value       = google_cloud_run_service.turbo_cache_server.status[0].url
}

output "gcs_bucket_name" {
  description = "GCS bucket name for turbo cache"
  value       = google_storage_bucket.turbo_cache.name
}