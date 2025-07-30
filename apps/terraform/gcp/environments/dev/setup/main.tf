terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "master" {
  source        = "../../../modules/setup"
  project_id    = var.project_id
  region        = var.region
  zone          = var.zone
  # environment   = var.environment
  machine_type  = var.machine_type
  instance_name = var.instance_name
  # インスタンス基本設定
  enable_preemptible = var.enable_preemptible
  boot_disk_image    = var.boot_disk_image
  boot_disk_size     = var.boot_disk_size
  boot_disk_type     = var.boot_disk_type
  network_name       = var.network_name
  enable_public_ip   = var.enable_public_ip
  # SSH設定
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  # 起動スクリプト
  startup_script = var.startup_script
  # メタデータとラベル
  custom_metadata = var.custom_metadata
  labels          = var.labels
  network_tags    = var.network_tags
}