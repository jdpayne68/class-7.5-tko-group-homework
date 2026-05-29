output "network" {
  value = google_compute_network.wk11_gcp.self_link
}

output "network_id" {
  value = google_compute_network.wk11_gcp.id
}

output "lb_ip" {
  value = "http://${google_compute_address.wk11_front.address}"
}