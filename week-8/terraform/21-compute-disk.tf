# ================================================================
# COMPUTE — DISKS
# ================================================================

# ----------------------------------------------------------------
# Disk — Balanced App
# ----------------------------------------------------------------
# Documentation - Compute Disk
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk
# https://docs.cloud.google.com/compute/docs/disks/persistent-disks

# resource "google_compute_disk" "balanced_app" {
#   name = "${local.name_prefix}-balanced-app-disk"
#   zone = "us-central1-a"
#   size = 200

#   physical_block_size_bytes = 4096
# }

# ----------------------------------------------------------------
# Disk Attachment — Balanced App Disk to Public App VM
# ----------------------------------------------------------------
# Documentation - Attached Disk
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk

# resource "google_compute_attached_disk" "balanced_app_to_public_app_vm" {
#   disk     = google_compute_disk.balanced_app.id
#   instance = google_compute_instance.public_app_vm.id
# }