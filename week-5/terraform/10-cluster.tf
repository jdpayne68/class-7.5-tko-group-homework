# ----------------------------------------------------------------
# GKE CLUSTER
# ----------------------------------------------------------------
# Kubernetes control plane, core networking, and security settings

resource "google_container_cluster" "dev_main_cluster" {
  name     = "dev-main-cluster"
  location = "us-central1-a"

  # Remove default node pool (managed separately via node pools)
  remove_default_node_pool = true
  initial_node_count       = 1


  # Set to false to allow Terraform to destroy cluster
  deletion_protection = false

  # Attach cluster to custom VPC and private subnet
  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.private.self_link

  # Enable GKE-native logging and monitoring (Cloud Ops)
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Use VPC-native networking (alias IPs for pods/services)
  networking_mode = "VPC_NATIVE"

  # Optional: limit cluster to specific zones (regional control)
  # node_locations = ["us-central1-a"]

  addons_config {
    # Disable legacy HTTP LB (use modern ingress/controllers)
    http_load_balancing {
      disabled = true
    }

    # Enable Horizontal Pod Autoscaler (HPA)
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  # Managed release channel (controls Kubernetes version upgrades)
  release_channel {
    channel = "REGULAR"
  }

  # Enable Workload Identity (pods → GCP IAM access)
  workload_identity_config {
    workload_pool = "kirk-devsecops-sandbox.svc.id.goog"
  }

  # Secondary IP ranges for pods and services (VPC-native requirement)
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  # Private cluster: nodes have no public IPs
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # API still publicly reachable (can restrict later)
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Ensures networking and required APIs exist before cluster creation
  depends_on = [
    google_compute_subnetwork.private,
    google_compute_router_nat.nat,
    google_project_service.container
  ]
}

# Optional: restrict API server access to trusted CIDRs (e.g., Jenkins)
# master_authorized_networks_config {
#   cidr_blocks {
#     cidr_block   = "10.0.0.0/18"
#     display_name = "private-subnet-w-jenkins"
#   }
# }