
# firewall for week 9 http

resource "google_compute_firewall" "wk-9-allow-http" {
  name    = "wk-9-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
    target_tags   = ["http-server"] # this tag will be used to allow traffic to the instances that have this tag
}

# firewall for week 9 ssh
resource "google_compute_firewall" "wk-9-allow-ssh" {
  name    = "wk-9-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # this allows traffic from any IP address to access the instances with the ssh-server tag on port 22, which is the default port for SSH. In a production environment, you would typically restrict this to specific IP ranges for security reasons.
  target_tags   = ["ssh-server"] # this tag will be used to allow traffic to the instances that have this tag
}