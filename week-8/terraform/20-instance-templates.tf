# ================================================================
# COMPUTE — INSTANCE TEMPLATES
# ================================================================

# ----------------------------------------------------------------
# Regional Instance Template — Public App
# ----------------------------------------------------------------
# Use a regional instance template to isolate hardware errors to the template's region.
# This also isolates regional resources from from outaes that affect globally scoped Compute Engine services.
# https://docs.cloud.google.com/compute/docs/instance-templates

# Documentation - Instance Templates
# https://docs.cloud.google.com/compute/docs/instance-templates/create-instance-templates#terraform
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template

resource "google_compute_region_instance_template" "public_app" {
  name         = "${local.name_prefix}-public-app-instance-template"
  machine_type = "n4d-standard-2"
  description  = "Instance template for public app instances."
  disk {
    source_image = "centos-stream-10"
    disk_type    = "hyperdisk-balanced"
    disk_size_gb = 100
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id

    # Configure Static External IP Address
    # Documentation - Extrnal IP Address
    # https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address
    # https://docs.cloud.google.com/compute/docs/ip-addresses/configure-static-external-ip-address#terraform_1
    access_config {}
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  # Use Aaron's startup script file
  metadata_startup_script = file("${path.module}/../scripts/aarons_scripts/userscripts/startup.sh")

  metadata = {
    homework = "bam-2"
  }

  tags = ["public-app-vm"]

  labels = {
    environment = "dev"
  }

}