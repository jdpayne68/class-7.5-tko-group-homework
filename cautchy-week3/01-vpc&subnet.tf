# Create the new VPC network
resource "google_compute_network" "cautch_says_vpc" {
  name                    = "cautch-says-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cautch_says_subnet_a" {
  name          = "cautch-says-subnet-a"
  ip_cidr_range = "192.168.225.0/24"
  region        = var.region
  network       = google_compute_network.cautch_says_vpc.name
}