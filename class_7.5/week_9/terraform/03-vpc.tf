# creating a vpc network 
resource "google_compute_network" "vpc_network" {
  name                    = "wk-9-vpc-network"
  auto_create_subnetworks = true
  mtu                    = 1460 #mtu means maximum transmission unit, which is the size of the largest packet that can be transmitted over a network. Setting it to 1460 is common for VPC networks in Google Cloud.
}