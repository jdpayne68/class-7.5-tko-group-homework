resource "google_compute_firewall" "allow_http" {
  name    = "${local.name_prefix}-ahttp"
  network = google_compute_network.alpha.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] # turns on http in firewall
}

resource "google_compute_firewall" "allow_https" {
  name    = "${local.name_prefix}-ahttps"
  network = google_compute_network.alpha.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name_prefix}-ssh"
  network = google_compute_network.alpha.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
}
