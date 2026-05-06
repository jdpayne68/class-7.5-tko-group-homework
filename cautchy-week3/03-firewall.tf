# A firewall rule so port 80 can sing to the world.
resource "google_compute_firewall" "cautch_says_http" {
  name    = "cautch-says-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}