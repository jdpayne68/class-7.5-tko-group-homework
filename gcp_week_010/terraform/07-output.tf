output "network" {
  value = google_compute_network.wk10_gcp.name
}

output "network_id" {
  value = google_compute_network.wk10_gcp.id
}

output "health_check" {
  value = google_compute_health_check.wk10_autohealing.id
}

output "url_map" {
  value = google_compute_url_map.wk10_star_link.id
}

output "backend" {
  value = google_compute_backend_service.wk10_rear_guard.id
}

output "proxy" {
  value = google_compute_target_http_proxy.wk10_barrier.id
}

output "instance_group_manager" {
  value = google_compute_region_instance_group_manager.wk10_overseer.id
}

output "template" {
  value = google_compute_instance_template.wk10_double.self_link_unique
}

output "lb_ip" {
  value = "http://${google_compute_global_address.frontend.address}"
}