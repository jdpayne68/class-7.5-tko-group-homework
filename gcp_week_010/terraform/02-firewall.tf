resource "google_compute_firewall" "wk10_http" {
  name    = "${local.name_prefix}-http"
  network = google_compute_network.wk10_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] # turns on http in firewall
}


resource "google_compute_firewall" "wk10_ssh" {
  name    = "${local.name_prefix}-ssh"
  network = google_compute_network.wk10_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}
