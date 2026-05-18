resource "google_compute_instance_template" "wk9_template" {
  name_prefix  = "wk9"
  machine_type = "e2-medium"
  region       = "us-east1"

  tags = ["http-server"] #connects to firewall target_tag

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.wk9_gcp.id

    access_config {}
  }

  metadata_startup_script = file("./startup.sh")

}