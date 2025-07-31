# プロジェクト基本設定
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "terraform-gcp-466623"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

# variable "environment" {
#   description = "Environment name (dev, staging, prod)"
#   type        = string
#   default     = "dev"
# }

# 基本設定
variable "machine_type" {
  description = "Machine type for compute instance"
  type        = string
  default     = "e2-micro"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "sample-instance"
}

# インスタンス基本設定
variable "enable_preemptible" {
  description = "Whether to use preemptible (Spot) instances"
  type        = bool
  default     = true
}

variable "boot_disk_image" {
  description = "Boot disk image for instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "default"
}

variable "enable_public_ip" {
  description = "Whether to enable public IP"
  type        = bool
  default     = true
}

# SSH設定
variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "terraform-user"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

# 起動スクリプト
variable "startup_script" {
  description = "Startup script to run on instance boot"
  type        = string
  default     = ""
}

# メタデータとラベル
variable "custom_metadata" {
  description = "Custom metadata for the instance"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels for the instance"
  type        = map(string)
  default     = {}
}

variable "network_tags" {
  description = "Network tags for the instance"
  type        = list(string)
  default     = ["http-server", "https-server", "ssh"]
}

# IAM関連の変数
variable "dev_team_group" {
  description = "Development team Google group email"
  type        = string
  default     = "terraform-dev-team@googlegroups.com"
}

