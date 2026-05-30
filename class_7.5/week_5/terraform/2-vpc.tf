# STAGE 2: VPC FOUNDATION
# Goal:
# - Enable required APIs
# - Create custom VPC
#
# Verify:
# - Compute API enabled
# - VPC named "main" exists
#
# Screenshot required:
# - API page
# - VPC Networks page


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
# Enable the Compute API so that we can create VPC networks and other compute resources
resource "google_project_service" "compute" {
  
  service = "compute.googleapis.com"
  disable_on_destroy = false
}


# Enable the GKE API so that we can create Kubernetes clusters
resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network 
# what this does is create a custom VPC network named "main" with regional routing, no automatic subnet creation, a specified MTU, and it keeps the default routes
resource "google_compute_network" "main3" {
  name                            = "main3"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  # Make sure the required APIs are enabled before creating the network
  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}