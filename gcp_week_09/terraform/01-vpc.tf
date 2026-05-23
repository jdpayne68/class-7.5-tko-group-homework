resource "google_compute_network" "wk9_gcp" {
  name                    = "wk9-gcp"
  auto_create_subnetworks = true
  mtu                     = 1460
}


resource "google_compute_subnetwork" "wk9_link" {
  name          = "wk9-subnetwork"
  ip_cidr_range = "10.30.0.0/24"
  network       = google_compute_network.wk9_gcp.id
}
