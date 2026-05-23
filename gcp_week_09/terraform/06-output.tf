output "network" {
  value = google_compute_network.wk9_gcp.id
  description = "name or self_link of the network to attach this interface to"
}

output "subnetwork" {
  value = google_compute_subnetwork.wk9_link.id
  description = "name of the subnetwork to attach this interface to"
}