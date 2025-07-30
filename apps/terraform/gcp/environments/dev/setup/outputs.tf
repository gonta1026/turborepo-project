output "instance_name" {
  description = "Name of the created instance"
  value       = module.master.instance_name
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = module.master.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = module.master.instance_private_ip
}

output "instance_zone" {
  description = "Zone where the instance is located"
  value       = module.master.instance_zone
}

output "http_url" {
  description = "HTTP URL to access the web server"
  value       = module.master.http_url
}

output "https_url" {
  description = "HTTPS URL to access the web server"
  value       = module.master.https_url
} 