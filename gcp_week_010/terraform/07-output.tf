output "network" {
  value = google_compute_network.wk10_gcp.self_link
}

output "network_id" {
  value = google_compute_network.wk10_gcp.id
}

output "lb_ip" {
  value = "http://${google_compute_global_address.wk10_front.address}"
}