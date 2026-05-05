# ----------------------------------------------------------------
# NODE POOL
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# NODE POOL - SPOT WORKERS
# ----------------------------------------------------------------
# Default node pool for regular workloads.
# Fixed size (no autoscaling) for predictable baseline capacity.
resource "google_container_node_pool" "general_workers" {
  name       = "general-workers"
  cluster    = google_container_cluster.dev_main_cluster.id
  node_count = 1

  # Ensures nodes self-heal and stay updated
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n2-standard-8"

    # Labels used for workload scheduling/selection
    labels = {
      role = "general"
    }

    # Attach service account (node identity)
    service_account = google_service_account.kubernetes.email

    # Broad API access (can be modified later to follow principle of least privilege)
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Ensures cluster exists before node pool is created
  depends_on = [
    google_container_cluster.dev_main_cluster
  ]
}

# ----------------------------------------------------------------
# NODE POOL - SPOT WORKERS
# ----------------------------------------------------------------
# Use spot VMs for non-critical or fault-tolerant workloads.
resource "google_container_node_pool" "spot_workers" {
  name    = "spot-workers"
  cluster = google_container_cluster.dev_main_cluster.id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Autoscaling configuration
  autoscaling {
    min_node_count = 0
    max_node_count = 3
  }

  node_config {
    spot         = true
    machine_type = "n2-standard-8"

    # Label for workload targeting
    labels = {
      team = "devops"
    }

    # Taint prevents normal workloads from scheduling here
    # Only pods with matching toleration can run on spot nodes
    taint {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }

    # Same service account used across node pools
    service_account = google_service_account.kubernetes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [
    google_container_cluster.dev_main_cluster
  ]
}