# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule#example-usage---global-forwarding-rule-external-managed

resource "google_compute_global_address" "phi" {
  name = "${local.name_prefix}-front"
}

###############
# HTTP
###############

resource "google_compute_url_map" "zeta" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.pi.id
}

resource "google_compute_target_http_proxy" "theta" {
  name    = "${local.name_prefix}-proxy"
  url_map = google_compute_url_map.zeta.id
}

resource "google_compute_global_forwarding_rule" "omega" {
  name                  = "${local.name_prefix}-http"
  target                = google_compute_target_http_proxy.theta.id
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED" # make it not classic application # EXTERNAL is default and is the classic
  ip_address            = google_compute_global_address.phi.address
}

###############
# HTTPS
###############


resource "google_compute_target_https_proxy" "theta_2" {
  name    = "${local.name_prefix}-sproxy"
  url_map = google_compute_url_map.zeta.id
  ssl_certificates = [data.google_compute_ssl_certificate.nwo.id] #if use change this 
}

resource "google_compute_global_forwarding_rule" "omega_2" {
  name                  = "${local.name_prefix}-https"
  target                = google_compute_target_https_proxy.theta_2.id
  port_range            = "443"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED" # make it not classic application # EXTERNAL is default and is the classic
  ip_address            = google_compute_global_address.phi.address
}

data "google_compute_ssl_certificate" "nwo" {
  name = "nwo"
}