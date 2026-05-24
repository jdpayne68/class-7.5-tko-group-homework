locals {
  name_prefix = "wk10"
}

resource "google_compute_network" "wk10_gcp" {
  name                    = "${local.name_prefix}-gcp"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "wk10_power_core" {
  name          = "${local.name_prefix}-subnetwork"
  ip_cidr_range = "10.50.0.0/24"
  network       = google_compute_network.wk10_gcp.id
}