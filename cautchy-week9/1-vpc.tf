resource "google_compute_network" "main" {
  name                    = var.network_name
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}