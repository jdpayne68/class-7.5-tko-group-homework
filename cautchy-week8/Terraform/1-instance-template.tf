resource "google_compute_instance_template" "bunda_template" {
  name_prefix  = "bunda-template"
  machine_type = "n2-standard-2"
  region       = var.region

  tags = ["http-server"]

  // boot disk configuration
  disk {
    source_image = "centos-cloud/centos-stream-10"
    auto_delete  = true
    disk_size_gb = 100
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