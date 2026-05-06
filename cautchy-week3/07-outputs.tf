# Outputs are how automation speaks to other automation.
output "vm_external_ip" {
  value = google_compute_instance.cautch_says_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_url" {
  value = "http://${google_compute_instance.cautch_says_vm.network_interface[0].access_config[0].nat_ip}"
}