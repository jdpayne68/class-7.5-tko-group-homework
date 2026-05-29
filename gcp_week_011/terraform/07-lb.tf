#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address#example-usage---address-with-subnetwork
resource "google_compute_address" "wk11_front" {
  name         = "${local.name_prefix}-front"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.valkyrie.id #use default subnet
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule#example-usage---forwarding-rule-http-lb
resource "google_compute_region_url_map" "wk11_star_link" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_region_backend_service.wk11_rear_guard.id
}

resource "google_compute_region_target_http_proxy" "wk11_barrier" {
  name    = "${local.name_prefix}-proxy"
  url_map = google_compute_region_url_map.wk11_star_link.id
}

#this is the default subnet
resource "google_compute_subnetwork" "valkyrie" { 
  name          = "${local.name_prefix}-subnet" 
  ip_cidr_range = "10.30.11.0/24"
  network       = google_compute_network.wk11_gcp.id
}

resource "google_compute_forwarding_rule" "wk11_glb" {
  name                  = "${local.name_prefix}-lb"
  target                = google_compute_region_target_http_proxy.wk11_barrier.id
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_address            = google_compute_address.wk11_front.address
  network               = google_compute_network.wk11_gcp.id
  subnetwork            = google_compute_subnetwork.valkyrie.id # use default subnet
  # depends_on = [google_compute_subnetwork.wk11_power_core]
}


