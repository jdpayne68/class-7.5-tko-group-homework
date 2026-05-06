resource "google_compute_instance" "cautch_says_vm" {
  name         = var.vm_name
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    access_config {} # External IP
  }

  metadata = {
    # The banner is identity. Make it yours.
    student_name = var.student_name
  }

  tags = ["cautch-says-web"]

  # The startup script is your first automation spell.
  metadata_startup_script = file("startup_script.sh")
}