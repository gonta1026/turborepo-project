variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

# variable "environment" {
#   description = "Environment name (dev, staging, prod)"
#   type        = string
# }

variable "machine_type" {
  description = "Machine type for compute instance"
  type        = string
  default     = "e2-micro"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "terraform-instance"
}

variable "enable_public_ip" {
  description = "Whether to enable public IP"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the instance"
  type        = map(string)
  default     = {}
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

# SSH設定
variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "terraform-user"
}

# 起動スクリプト
variable "startup_script" {
  description = "Startup script to run on instance boot"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    # 基本パッケージの更新
    apt-get update
    apt-get install -y nginx htop curl
    
    # nginxの設定
    systemctl enable nginx
    systemctl start nginx
    
    # 簡単なHTMLページの作成
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Terraform GCP Instance</title>
    </head>
    <body>
        <h1>Hello from Terraform!</h1>
        <p>Instance created at: $(date)</p>
        <p>Hostname: $(hostname)</p>
    </body>
    </html>
HTML
    
    # ログ出力
    echo "Startup script completed at $(date)" >> /var/log/startup-script.log
  EOF
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

# サービスアカウント設定
variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Service account scopes"
  type        = list(string)
  default     = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
}
