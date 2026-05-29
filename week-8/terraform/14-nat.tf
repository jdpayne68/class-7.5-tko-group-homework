# ================================================================
# NETWORKING — NAT
# ================================================================

# ----------------------------------------------------------------
# NAT
# ----------------------------------------------------------------

resource "google_compute_router_nat" "nat" {
  name   = "${local.name_prefix}-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]

  # Dependency is implicit in the "router" argument (references google_compute_router.router.name)
  # depends_on = [
  #   google_compute_router.router
  # ]
}

# ----------------------------------------------------------------
# NAT - External IP Address
# ----------------------------------------------------------------
# Documentation - External IP Address
# https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address

resource "google_compute_address" "nat" {
  name         = "${local.name_prefix}-nat-ip"
  region       = "us-central1"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  # Helpful, but not needed when the required API has already been enabled.
  # depends_on = [google_project_service.compute]
}