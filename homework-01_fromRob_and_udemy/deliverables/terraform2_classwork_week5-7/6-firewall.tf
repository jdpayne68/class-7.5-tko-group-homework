resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Lab only

  depends_on = [
    google_compute_network.main
  ]
}

# This file defines a Google Cloud Firewall resource that will be used to allow incoming HTTP traffic to instances in the main subnet. The firewall rule will allow TCP traffic on port 80 from any source IP address, which is necessary for web servers that need to serve content over HTTP. The firewall rule will be associated with the main network and will ensure that instances in the main subnet can receive incoming HTTP traffic while still being protected by the firewall rules defined for the network.
resource "google_compute_firewall" "allow_http-main" {
  name    = "allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}


# This file defines a Google Cloud Firewall resource that will be used to allow incoming HTTPS traffic to instances in the main subnet. The firewall rule will allow TCP traffic on port 443 from any source IP address, which is necessary for web servers that need to serve secure content over HTTPS. The firewall rule will be associated with the main network and will ensure that instances in the main subnet can receive incoming HTTPS traffic while still being protected by the firewall rules defined for the network.
resource "google_compute_firewall" "allow_https-main" {
  name    = "allow-https"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    #Lab only, in production you would want to limit this to specific IPs or ranges
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}