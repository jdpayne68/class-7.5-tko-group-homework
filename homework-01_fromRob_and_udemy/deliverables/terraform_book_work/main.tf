resource "google_compute_instance" "this" {
  project      = "training-416401"
  name         = "cloudshell"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // required for external IP
    }
  }
  metadata_startup_script = file("startup.sh")
  tags                    = ["http-server"]
}
