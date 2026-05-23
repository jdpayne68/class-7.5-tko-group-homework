# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule#example-usage---global-forwarding-rule-external-managed

resource "google_compute_global_address" "frontend" {
  name = "${local.name_prefix}-frontend"
}

resource "google_compute_url_map" "wk10_star_link" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.wk10_rear_guard.id
}

resource "google_compute_target_http_proxy" "wk10_barrier" {
  name    = "${local.name_prefix}-proxy"
  url_map = google_compute_url_map.wk10_star_link.id
}

resource "google_compute_global_forwarding_rule" "wk10_glb" {
  name                  = "${local.name_prefix}-global"
  target                = google_compute_target_http_proxy.wk10_barrier.id
  port_range            = "80"
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED" # make it not classic application # EXTERNAL is default and is the classic
  ip_address = google_compute_global_address.frontend.address
}


