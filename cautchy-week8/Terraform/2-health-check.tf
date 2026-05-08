resource "google_compute_health_check" "bunda_health_check" {
  name                = "bunda-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/bunda_health"
  }

  log_config {
    enable = true
  }
}