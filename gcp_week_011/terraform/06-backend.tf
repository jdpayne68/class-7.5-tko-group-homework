resource "google_compute_region_health_check" "wk11_lb" {
  name                = "${local.name_prefix}-lb"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    # request_path = "/healthz"
    port = "80"
  }
}

resource "google_compute_region_backend_service" "wk11_rear_guard" {
  name                  = "${local.name_prefix}-backend"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.wk11_lb.id]

  backend {
    group           = google_compute_region_instance_group_manager.wk11_overseer.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}