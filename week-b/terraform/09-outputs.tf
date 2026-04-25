# ----------------------------------------------------------------
# OUTPUTS
# ----------------------------------------------------------------

output "vm_name" {
  description = "Name of the VM"
  value       = google_compute_instance.vm_dashboard.name
}

output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.vm_dashboard.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "gcloud compute ssh ${google_compute_instance.vm_dashboard.name} --zone us-central1-a"
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.vm_dashboard.network_interface[0].network_ip
}

output "kubectl_get_nodes" {
  value = "kubectl get nodes"
}

output "gke_get_credentials_command" {
  value = "gcloud container clusters get-credentials dev-main-cluster --zone us-central1-a --project kirk-devsecops-sandbox"
}