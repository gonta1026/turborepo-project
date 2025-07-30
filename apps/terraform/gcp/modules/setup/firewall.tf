# HTTP用のファイアウォールルール（インスタンス固有）
resource "google_compute_firewall" "allow_http" {
  name        = "${var.instance_name}-allow-http"
  network     = var.network_name
  project     = var.project_id
  description = "Allow HTTP access to ${var.instance_name} instance"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.instance_name}-http"]
}

# HTTPS用のファイアウォールルール（インスタンス固有）
resource "google_compute_firewall" "allow_https" {
  name        = "${var.instance_name}-allow-https"
  network     = var.network_name
  project     = var.project_id
  description = "Allow HTTPS access to ${var.instance_name} instance"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.instance_name}-https"]
}

# SSH用のファイアウォールルール（インスタンス固有）
resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.instance_name}-allow-ssh"
  network     = var.network_name
  project     = var.project_id
  description = "Allow SSH access to ${var.instance_name} instance"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.instance_name}-ssh"]
}

# 汎用のファイアウォールルール（既存のnetwork_tagsとの互換性のため）
resource "google_compute_firewall" "allow_general_http" {
  name        = "allow-general-http"
  network     = var.network_name
  project     = var.project_id
  description = "Allow HTTP access to instances with http-server tag"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_general_https" {
  name        = "allow-general-https"
  network     = var.network_name
  project     = var.project_id
  description = "Allow HTTPS access to instances with https-server tag"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "allow_general_ssh" {
  name        = "allow-general-ssh"
  network     = var.network_name
  project     = var.project_id
  description = "Allow SSH access to instances with ssh tag"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}