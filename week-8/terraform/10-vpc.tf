# ================================================================
# NETWORKING — VPC
# ================================================================

# ----------------------------------------------------------------
# VPC — Main
# ----------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "${local.name_prefix}-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  # Helpful, but not needed when the required API has already been enabled.
  # depends_on = [
  #   google_project_service.compute,
  # ]
}