# GCP Project Configuration
project_id = "terraform-gcp-466623"

# Region and Zone Configuration
region = "us-central1"
zone   = "us-central1-a"

# Environment Configuration
# environment   = "dev"

# Compute Instance Configuration
machine_type  = "e2-micro"
instance_name = "sample-instance"

# インスタンス基本設定
enable_preemptible = true
boot_disk_image    = "debian-cloud/debian-11"
boot_disk_size     = 11
boot_disk_type     = "pd-standard"
network_name       = "default"
enable_public_ip   = true

# SSH設定（実際のSSH公開鍵に置き換えてください）
ssh_user       = "terraform-user"
ssh_public_key = "" # ここに実際のSSH公開鍵を設定

# 起動スクリプト（カスタマイズ例）
startup_script = <<-EOF
#!/bin/bash
# システムの更新
apt-get update
apt-get install -y nginx htop curl git

# nginxの設定と起動
systemctl enable nginx
systemctl start nginx

# カスタムHTMLページの作成
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dev Environment - Terraform GCP</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { color: #4285f4; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1 class="header">🚀 Dev Environment Instance</h1>
    <div class="info">
        <h2>Instance Information</h2>
        <p><strong>Created:</strong> $(date)</p>
        <p><strong>Hostname:</strong> $(hostname)</p>
        <p><strong>Project:</strong> terraform-gcp-466623</p>
        <p><strong>Managed by:</strong> Terraform</p>
    </div>
    <h2>Services Status</h2>
    <p>✅ Nginx is running</p>
    <p>✅ System packages updated</p>
</body>
</html>
HTML

# ログディレクトリの作成
mkdir -p /var/log/terraform
echo "Startup script completed successfully at $(date)" >> /var/log/terraform/startup.log
echo "Instance ready for development work" >> /var/log/terraform/startup.log
EOF

# カスタムメタデータ
custom_metadata = {
  purpose       = "development"
  cost_center   = "engineering"
  auto_shutdown = "true"
}

# ラベル設定
labels = {
  purpose    = "terraform-state"
  managed_by = "terraform"
}

# ネットワークタグ設定
network_tags = ["http-server", "https-server", "ssh", "sample-instance"]

# IAM設定（dev環境は編集者権限でシンプルに）
dev_team_group = "terraform-gcp-dev-team@googlegroups.com"
