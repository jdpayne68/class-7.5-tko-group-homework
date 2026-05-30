
# This file defines a Google Cloud Router resource that will be used to manage dynamic routing for the network. need router to create nat gateway, and nat gateway is needed to allow instances in the private subnet to access the internet. The router will be used to manage the routing for the nat gateway and ensure that traffic from the private subnet can reach the internet through the nat gateway. The router will also be used to manage any dynamic routing protocols that may be needed in the future as the network grows and evolves.
resource "google_compute_router" "router" {
  name    = "router"
  region  = "us-central1"
  network = google_compute_network.main.id


# BGP (Border Gateway Protocol) is a standardized exterior gateway protocol used to exchange routing information between different networks on the internet. 
  bgp {
    asn = 64514
  }


  depends_on = [
    google_compute_network.main
  ]
}