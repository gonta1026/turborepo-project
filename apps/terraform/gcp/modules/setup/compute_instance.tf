# Cloud Storage bucket for static website hosting
# Note: 将来的にdashboardアプリをデプロイする際に使用
# 
# resource "google_storage_bucket" "website_bucket" {
#   name     = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-dashboard"
#   location = var.region
#   
#   # 静的ウェブサイトホスティング用の設定
#   website {
#     main_page_suffix = "index.html"
#     not_found_page   = "404.html"
#   }
#   
#   # パブリックアクセス用の設定
#   uniform_bucket_level_access = true
#   
#   labels = merge(
#     {
#       managed_by = "terraform"
#       purpose    = "static-website"
#     },
#     var.labels
#   )
# }

# Cloud CDN用の設定（将来的に追加予定）
# - HTTP(S) Load Balancer
# - SSL Certificate（カスタムドメイン使用時）
# - Backend bucket configuration
