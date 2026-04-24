# STAGE 2: VPC FOUNDATION
# Goal:
# - Enable required APIs
# - Create custom VPC
#
# Verify:
# - Compute API enabled
# - VPC named "main-2" exists
#
# Screenshot required:
# - API page
# - VPC Networks page


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
# Enable the Compute API so that we can create VPC networks and other compute resources
resource "google_project_service" "compute2" {
  
  service = "compute.googleapis.com"
  disable_on_destroy = false
}


# Enable the GKE API so that we can create Kubernetes clusters
resource "google_project_service" "container2" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network 
# what this does is create a custom VPC network named "main" with regional routing, no automatic subnet creation, a specified MTU, and it keeps the default routes
resource "google_compute_network" "main-2" {
  name                            = "main-2"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  # mtu stands for Maximum Transmission Unit, which is the size of the largest protocol data unit that can be communicated in a single network layer transaction. Setting it to 1460 is common for GCP VPC networks to optimize performance and reduce fragmentation.
  mtu                             = 1460
  delete_default_routes_on_create = false

  # Make sure the required APIs are enabled before creating the network
  depends_on = [
    google_project_service.compute2,
    google_project_service.container2
  ]
}

# so the steps are this:
# 1. Enable the Compute API and GKE API using google_project_service resources
# 2. Create a custom VPC network named "main-2" with specific settings using google_compute_network resource    
# The VPC network is created after the APIs are enabled due to the depends_on attribute, ensuring that there are no dependency issues during deployment.