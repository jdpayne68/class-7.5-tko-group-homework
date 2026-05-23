resource "google_compute_instance_template" "wk9_clone" {
  name_prefix  = "wk9"
  machine_type = "e2-medium"

  tags = ["http-server", "ssh-access"] #connects to firewall target_tag

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.wk9_gcp.id
    subnetwork = google_compute_subnetwork.wk9_link.id
    

    access_config {} # allows a public external ip
  }

  metadata_startup_script = file("./startup.sh")

}