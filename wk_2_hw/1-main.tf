resource "google_compute_instance" "valkyrie" {
  name         = var.vm_name
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

network_interface {
    network = "default"

    access_config {}
  }

  metadata = {
  
    student_name = var.student_name

    startup-script = file("${path.module}/user_data.sh")  # On GCP, this is called a startup script, not EC2-style user_data
    # startup-script = file("${path.module}/gate_lab2_http.sh")
  }
  tags = ["valkyrie-web"]
}

#############
# Firewall 
#############

resource "google_compute_firewall" "valkyrie_firewall" {
  name    = "valkyrie-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}



output "vm_external_ip" {
  value = google_compute_instance.valkyrie.network_interface[0].access_config[0].nat_ip
}

output "vm_url" {
  value = "http://${google_compute_instance.valkyrie.network_interface[0].access_config[0].nat_ip}"
}