#Go to:
#VPC Network → Subnets
#Confirm:

#    subnet exists
#    secondary ranges visible


# what we are doing here:
# creating a subnet with secondary ranges for pods and services
# the secondary ranges are required for VPC-native GKE clusters
resource "google_compute_subnetwork" "private" {
  name                     = "private-subnet"
  # CIDR range for the primary IP range of the subnet. This is the range from which VM instances will get their primary IP addresses.
  ip_cidr_range            = "10.0.0.0/18"
  region                   = "us-central1"
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  # IMPORTANT:
  # These CIDR ranges MUST NOT overlap
  # Do not modify unless you understand subnetting

  # The secondary IP range for pods must be large enough to accommodate the number of pods you expect to run in your cluster. Each pod gets an IP address from this range.
  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  # The secondary IP range for services must be large enough to accommodate the number of services you expect to run in your cluster. Each service gets an IP address from this range.
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }

 # This ensures that the subnet is created after the VPC network is created, preventing any dependency issues during deployment.
  depends_on = [
    google_compute_network.main
  ]
}

