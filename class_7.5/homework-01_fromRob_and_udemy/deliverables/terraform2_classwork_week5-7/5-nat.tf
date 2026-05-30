# This file defines a Google Cloud NAT (Network Address Translation) resource that will be used to allow instances in the private subnet to access the internet. The NAT gateway will be associated with the router defined in the 4_router.tf file, and it will be configured to use a static external IP address for outbound traffic. The NAT gateway will also be configured to allow all IP ranges from the private subnet to be translated to the external IP address, enabling instances in the private subnet to communicate with the internet while keeping their internal IP addresses hidden.
resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]

  depends_on = [
    google_compute_router.router
  ]
}

# This file defines a Google Cloud Router resource that will be used to manage dynamic routing for the network. need router to create nat gateway, and nat gateway is needed to allow instances in the private subnet to access the internet. The router will be used to manage the routing for the nat gateway and ensure that traffic from the private subnet can reach the internet through the nat gateway. The router will also be used to manage any dynamic routing protocols that may be needed in the future as the network grows and evolves.
resource "google_compute_address" "nat" {
  name         = "nat"
  region       = "us-central1"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}