output "static_ip_address" {
  description = "Static IP address for DNS A record"
  value       = google_compute_global_address.dashboard_frontend.address
}

output "domain_name" {
  description = "Domain name to configure"
  value       = var.domain_name
}