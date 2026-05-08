output "internal_ip" {
  value = google_compute_instance.bunda_vm.network_interface[0].network_ip
}

output "external_ip" {
  value = google_compute_instance.bunda_vm.network_interface[0].access_config[0].nat_ip
}

output "external_url" {
  value = "http://${google_compute_instance.bunda_vm.network_interface[0].access_config[0].nat_ip}"
}