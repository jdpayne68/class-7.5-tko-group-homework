# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule#example-usage---global-forwarding-rule-external-managed

resource "google_compute_global_forwarding_rule" "wk10_glb" {
  name                  = "${local.name_prefix}-global"
  target                = google_compute_target_http_proxy.wk10_barrier.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED" # make it not classic application # EXTERNAL is default and is the classic
}

resource "google_compute_target_http_proxy" "wk10_barrier" {
  name    = "${local.name_prefix}-proxy"
  url_map = google_compute_url_map.wk10_star_link.id
}

resource "google_compute_url_map" "wk10_star_link" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.wk10_rear_guard.id
}

resource "google_compute_backend_service" "wk10_rear_guard" {
  name                  = "${local.name_prefix}-backend"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.wk10_autohealing.id]

  backend {
    group = google_compute_region_instance_group_manager.wk10_overseer.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

