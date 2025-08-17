# ======================================
# Shared Certificate Map
# ======================================

# 共通Certificate Map（全サービスの証明書を管理）
resource "google_certificate_manager_certificate_map" "shared_cert_map" {
  name        = "shared-cert-map"
  description = "Shared certificate map for all services (dashboard, api, etc.)"

  labels = {
    purpose    = "shared-certificate-map"
    managed_by = "terraform"
  }
}
