resource "google_compute_firewall" "wk9_http" {
  name    = "wk9-http"
  network = google_compute_network.wk9_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] # turns on http in firewall
}


resource "google_compute_firewall" "wk9_ssh" {
  name    = "wk9-ssh"
  network = google_compute_network.wk9_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
}
