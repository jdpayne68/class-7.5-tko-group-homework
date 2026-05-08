resource "google_compute_region_instance_group_manager" "bunda_mig" {
  name = "bunda-mig"

  base_instance_name        = "bunda-instance"
  region                    = var.region
  distribution_policy_zones = ["us-central1-a", "us-central1-f"]

  version {
    instance_template = google_compute_instance_template.bunda_template.self_link_unique
  }

  all_instances_config {
    metadata = {
      metadata_key = "metadata_value"
    }
    labels = {
      label_key = "label_value"
    }
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.bunda_health_check.self_link
    initial_delay_sec = 300
  }
}
