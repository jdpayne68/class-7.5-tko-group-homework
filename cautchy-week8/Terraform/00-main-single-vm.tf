resource "google_compute_instance" "bunda_vm" {
  name         = "bunda-vm"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100
    }
    auto_delete = true
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip       = "" #needed since we need the ephemeral public IP
      network_tier = "PREMIUM"
    }
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  lifecycle {
    create_before_destroy = true
  }
}