# ================================================================
# COMPUTE — VM INSTANCES
# ================================================================


# ----------------------------------------------------------------
# VM Instance — Public App VM
# ----------------------------------------------------------------
# Documantation -  Machine Families and Disks
# https://docs.cloud.google.com/compute/docs/machine-resource
# https://docs.cloud.google.com/compute/docs/disks/persistent-disks
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
resource "google_compute_instance" "public_app_vm_a" {
  name                      = "${local.name_prefix}-public-app-vm-instance-a"
  machine_type              = "n4d-standard-2"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "centos-stream-10"
      type  = "hyperdisk-balanced"
      size  = 100
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id

    # Configure static external IP address
    # https://docs.cloud.google.com/compute/docs/ip-addresses/configure-static-external-ip-address#terraform_1
    access_config {
      nat_ip = google_compute_address.public_app.address
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  # Use Aaron's startup script file
  metadata_startup_script = file("${path.module}/../scripts/aarons_scripts/userscripts/startup.sh")

  metadata = {
    homework = "bam-1"
  }

  # Documentation - Tags and Labels
  # https://docs.cloud.google.com/resource-manager/docs/tags/tags-overview
  # https://docs.cloud.google.com/resource-manager/docs/creating-managing-labels
  tags = ["public-app-vm"]

  depends_on = [
    # Dependency is implicit in the "subnetwork" argument (references google_compute_subnetwork.private.id)
    # google_compute_subnetwork.private,

    # Dependency must be declared explicitly here.
    # VM startup script depends on outbound internet access (requires NAT).
    google_compute_router_nat.nat
  ]
}

# ----------------------------------------------------------------
# VM Instance from Template — Public App VM
# ----------------------------------------------------------------
# Documentation - VM Instance from Template
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template

resource "google_compute_instance_from_template" "public_app_vm_b" {
  name = "${local.name_prefix}-public-app-vm-instance-b"
  zone = "us-central1-a"

  source_instance_template = google_compute_region_instance_template.public_app.name

  # NOTE: Instance template tag wasn't propagated to the VM. Applying directly to the VM resource a workaround.
  # tags = ["public-app-vm"]

  depends_on = [
    # Dependency must be declared explicitly here.
    # VM startup script depends on outbound internet access (requires NAT).
    google_compute_router_nat.nat
  ]
}