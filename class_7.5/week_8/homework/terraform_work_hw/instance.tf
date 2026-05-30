resource "google_compute_instance" "web_vm" {
  name         = "centos-stream10-web"
  # machine_type = "n2-standard-2" # N-series machine type
  machine_type = "e2-standard-4" # E-series machine type

  zone         = "us-central1-b"

  tags = ["http-server"] # Enables port 80 via default firewall rule

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100 # 100 GB root disk
    }
  }

  network_interface {
    network = "default"

    # Creates an external IP
    access_config {}
  }

  # Load startup script from file
  metadata_startup_script = file("${path.module}/startup.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  description = "CentOS Stream 10 VM with external IP and startup script"
}
