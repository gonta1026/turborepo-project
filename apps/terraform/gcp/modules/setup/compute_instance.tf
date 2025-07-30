resource "google_compute_instance" "sample_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  
  # VMを停止状態で作成/維持（必要に応じてコメントアウト）
  # desired_status = "TERMINATED"
  
  # Spotインスタンス（プリエンプティブル）で最大90%コスト削減
  scheduling {
    preemptible = var.enable_preemptible
    automatic_restart = false
    on_host_maintenance = "TERMINATE"
  }

  # ブートディスク設定
  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  # ネットワーク設定
  network_interface {
    network = var.network_name
    
    # パブリックIPの設定（SSH接続のため）
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }

  # メタデータ設定（SSH、起動スクリプト含む）
  metadata = merge(
    {
      # SSH公開鍵の設定
      ssh-keys = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : ""
      
      # 起動スクリプト
      startup-script = var.startup_script
      
      # 基本メタデータ
      managed-by = "terraform"
    },
    var.custom_metadata
  )

  # サービスアカウント設定
  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  # タグ設定（instance_nameを使った固有タグを含める）
  tags = concat(
    [
      "${var.instance_name}-ssh",
      "${var.instance_name}-http",
      "${var.instance_name}-https"
    ],
    var.network_tags
  )

  # ラベル設定
  labels = merge(
    {
      managed_by    = "terraform"
      instance_type = "single"
      instance_name = var.instance_name
    },
    var.labels
  )

  # ライフサイクル設定
  lifecycle {
    create_before_destroy = false
    ignore_changes = [
      metadata["ssh-keys"]  # SSH鍵の手動変更を許可
    ]
  }
}