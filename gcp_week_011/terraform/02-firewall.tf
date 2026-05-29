resource "google_compute_firewall" "allow_http" {
  name    = "${local.name_prefix}-http"
  network = google_compute_network.wk11_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] # turns on http 
}


resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name_prefix}-ssh"
  network = google_compute_network.wk11_gcp.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"] # turns on ssh
}
