# External IP address of the VM
output "vm_external_ip" {
  description = "External IP address of the VM  this is public"
  value       = google_compute_instance.web_vm.network_interface[0].access_config[0].nat_ip
}

# Internal IP address of the VM
output "vm_internal_ip" {
  description = "Internal IP address of the VM, this is private"
  value       = google_compute_instance.web_vm.network_interface[0].network_ip
}

# VM name
output "vm_name" {
  description = "Name of the my vm instance"
  value       = google_compute_instance.web_vm.name
}

# VM ID
output "vm_id" {
  description = "Unique ID of the vm instance"
  value       = google_compute_instance.web_vm.id
}

# VM self_link
output "vm_self_link" {
  description = "Self link of the vm instance"
  value       = google_compute_instance.web_vm.self_link
}
