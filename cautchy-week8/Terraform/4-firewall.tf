resource "google_compute_firewall" "bunda_firewall_allow_http" {
  name    = "bunda-firewall-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}