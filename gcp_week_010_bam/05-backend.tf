resource "google_compute_health_check" "eta_2" {
  name                = "${local.name_prefix}-lb"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    # request_path = "/healthz"
    port = "80"
  }
}

resource "google_compute_backend_service" "pi" {
  name                  = "${local.name_prefix}-backend"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.eta_2.id]

  backend {
    group = google_compute_region_instance_group_manager.gamma.instance_group
  }

   backend {
    group = google_compute_region_instance_group_manager.omicron.instance_group
  }

   backend {
    group = google_compute_region_instance_group_manager.psi.instance_group
  }

}