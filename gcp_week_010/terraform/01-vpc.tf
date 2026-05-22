locals {
  name_prefix = "wk10"
}

resource "google_compute_network" "wk10_gcp" {
  name                    = "${local.name_prefix}-gcp"
  auto_create_subnetworks = true
  mtu                     = 1460
}
