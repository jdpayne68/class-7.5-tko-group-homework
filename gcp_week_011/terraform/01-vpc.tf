locals {
  name_prefix = "wk11"
}

resource "google_compute_network" "wk11_gcp" {
  name                    = "${local.name_prefix}-gcp"
  auto_create_subnetworks = false
  mtu                     = 1460
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#example-usage---subnetwork-internal-l7lb
resource "google_compute_subnetwork" "wk11_power_core" {
  name          = "${local.name_prefix}-subnetwork" #this is the proxy subnet
  ip_cidr_range = "10.50.0.0/23"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.wk11_gcp.id
}