locals {
  name_prefix = "wk10"
}

resource "google_compute_network" "alpha" {
  name                    = "${local.name_prefix}-gcp"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "beta" {
  name          = "${local.name_prefix}-subnetwork"
  ip_cidr_range = "10.50.0.0/16"
  network       = google_compute_network.alpha.id
}