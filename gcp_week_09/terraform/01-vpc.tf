resource "google_compute_network" "wk9_gcp" {
  name                    = "wk9-gcp"
  auto_create_subnetworks = true
  mtu                     = 1460
}
