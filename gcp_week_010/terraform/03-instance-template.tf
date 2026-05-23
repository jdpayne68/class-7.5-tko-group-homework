resource "google_compute_instance_template" "wk10_double" {
  name_prefix  = "wk10"
  machine_type = var.machine_type
  region       = var.region

  tags = ["http-server", "ssh-access"] #connects to firewall target_tag

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.wk10_gcp.id
    subnetwork = google_compute_subnetwork.wk10_power_core.id

    access_config {} # allows a public external ip
  }

  metadata_startup_script = file("./startup.sh")

}