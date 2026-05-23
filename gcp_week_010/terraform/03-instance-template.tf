resource "google_compute_instance_template" "wk10_double" {
  name_prefix  = "wk10"
  machine_type = var.machine_type
  region       = var.region

  tags = ["http-server"] #connects to firewall target_tag

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.wk10_gcp.id

    access_config {}
  }

  metadata_startup_script = file("./startup.sh")

}