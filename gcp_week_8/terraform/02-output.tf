output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.wk8_vm.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.wk8_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_name" {
  description = "Name of the VM"
  value       = google_compute_instance.wk8_vm.name

}

output "vm_id" {
  description = "Identifier for the resource"
  value       = google_compute_instance.wk8_vm.id

}

output "self_link" {
  description = " URI of the created resource"
  value       = google_compute_instance.wk8_vm.self_link

}