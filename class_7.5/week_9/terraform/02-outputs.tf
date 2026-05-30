# output for instance group manager
output "instance_group_manager_name" {
  value = google_compute_region_instance_group_manager.wk-9-instance-group-manager.name
}   


# output for autoscaler
output "autoscaler_name" {
  value = google_compute_region_autoscaler.instance_group_manager_autoscaler.name
}


# output for firewall rules
output "allow_http_firewall_rule_name" {
  value = google_compute_firewall.wk-9-allow-http.name
}

# output for firewall rules
output "allow_ssh_firewall_rule_name" {
  value = google_compute_firewall.wk-9-allow-ssh.name
}   
