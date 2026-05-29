resource "google_compute_router" "valkyrie_converter" {
    name = "${local.name_prefix}-router"
    network = google_compute_network.wk11_gcp.id
}

resource "google_compute_router_nat" "valkyrie_private" {
  name = "${local.name_prefix}-nat"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
  router = google_compute_router.valkyrie_converter.name
  nat_ip_allocate_option = "AUTO_ONLY"
}