# Output the internal IP address of the VM
output "internal_ip" {
  description = "The internal IP address of the VM"
  value       = google_compute_instance.vm.network_interface.0.network_ip
}

# Output the external IP address of the VM
output "external_ip" {
  description = "The external IP address of the VM"
  value       = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}

# Output the name of the VM
output "vm_name" {
  description = "The name of the VM"
  value       = google_compute_instance.vm.name
}

# Output the id of the VM
output "vm_id" {
  description = "The unique ID assigned by GCP"
  value       = google_compute_instance.vm.id
}

# Output the self_link of the VM
output "vm_self_link" {
  description = "The self link URI of the VM for use by other resources"
  value       = google_compute_instance.vm.self_link
}