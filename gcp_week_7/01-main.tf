resource "google_compute_instance" "week_7_vm" {
  name         = "week-7-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

network_interface {
    network = "default"

    access_config {}
  }
}

#VPC

resource "google_compute_network" "gcp_week_7_network" {
  name = "vpc-week-7"
}

#LOCAL FILE

resource "local_file" "favorite_food" {
  content  = "My favorite food is Chicken Philly!"
  filename = "${path.module}/favorite_food.txt"
}
