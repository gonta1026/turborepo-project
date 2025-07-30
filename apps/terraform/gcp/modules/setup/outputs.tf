output "instance_name" {
  description = "Name of the created instance"
  value       = google_compute_instance.sample_instance.name
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = length(google_compute_instance.sample_instance.network_interface[0].access_config) > 0 ? google_compute_instance.sample_instance.network_interface[0].access_config[0].nat_ip : "No public IP"
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = google_compute_instance.sample_instance.network_interface[0].network_ip
}

output "instance_zone" {
  description = "Zone where the instance is located"
  value       = google_compute_instance.sample_instance.zone
}

output "http_url" {
  description = "HTTP URL to access the web server"
  value       = length(google_compute_instance.sample_instance.network_interface[0].access_config) > 0 ? "http://${google_compute_instance.sample_instance.network_interface[0].access_config[0].nat_ip}" : "No public IP available"
}

output "https_url" {
  description = "HTTPS URL to access the web server"
  value       = length(google_compute_instance.sample_instance.network_interface[0].access_config) > 0 ? "https://${google_compute_instance.sample_instance.network_interface[0].access_config[0].nat_ip}" : "No public IP available"
} 