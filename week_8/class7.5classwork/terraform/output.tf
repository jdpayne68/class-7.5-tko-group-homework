output "instance_ip" {
    # Output the external IP address of the instance
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

# internal IP address
output "instance_internal_ip" {
    # Output the internal IP address of the instance
  value = google_compute_instance.default.network_interface[0].network_ip
}

output "instance_name" {
    # Output the name of the instance
  value = google_compute_instance.default.name
}

output "instance_zone" {
    # Output the zone of the instance
  value = google_compute_instance.default.zone
}

#boot disk image
output "boot_disk_image" {
    # Output the image used for the boot disk
  value = google_compute_instance.default.boot_disk[0].initialize_params[0].image
}

#network interface
output "network_interface" {
    # Output the network interface details
  value = google_compute_instance.default.network_interface[0]
}