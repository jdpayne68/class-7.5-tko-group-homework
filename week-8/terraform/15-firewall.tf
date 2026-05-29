# ================================================================
# NETWORKING — FIREWALL
# ================================================================

# ----------------------------------------------------------------
# Firewall Rule — Public App VM
# ----------------------------------------------------------------

resource "google_compute_firewall" "public_app_vm" {
  name    = "${local.name_prefix}-public-app-vm"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["public-app-vm"]
}