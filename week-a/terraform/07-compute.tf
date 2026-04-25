# ----------------------------------------------------------------
# COMPUTE
# ----------------------------------------------------------------

resource "google_compute_instance" "vm_dashboard" {
  name         = "devsecops-dashboard"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id

    # External IP for SSH (lab simplicity)
    access_config {}
  }

  # Use startup script file
  metadata_startup_script = file("${path.module}../scripts/gcp_startup.sh")

  # Configuration for template Files
#   metadata_startup_script = templatefile("${path.module}/templates/gcp_startup.sh.tpl",
#   {
#       template_var_1  = value,
#       template_var_2  = value,
#       template_var_3  = value,
#     }
#   )

  tags = ["ssh", "http", "http-server"]

  depends_on = [
    google_compute_subnetwork.private,
    google_compute_router_nat.nat
  ]
}



# 