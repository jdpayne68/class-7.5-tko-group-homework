# ================================================================
# NETWORKING — IP ADDRESSES
# ================================================================

# ----------------------------------------------------------------
# External IP Address - Public Application
# ----------------------------------------------------------------
# Documentation - External IP Address
# https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address

resource "google_compute_address" "public_app" {
  name   = "${local.name_prefix}-public-app-static-ip"
  region = "us-central1"
}