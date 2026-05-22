resource "google_compute_health_check" "wk10_autohealing" {
  name                = "wk10-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    # request_path = "/healthz"
    port = "80"
  }
}

#for creating multiple zones
######################
# MIG Multiply Zone 
######################
resource "google_compute_region_instance_group_manager" "wk10_manage" {
  name = "${local.name_prefix}-manage"

  base_instance_name        = "wk10"
  region                    = var.region
  distribution_policy_zones = ["${var.region}-b", "${var.region}-c", "${var.region}-d"]

  version {
    instance_template = google_compute_instance_template.wk10_template.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.wk10_autohealing.id
    initial_delay_sec = 300
  }
}


# for creating single zone
####################
# MIG Single Zone
####################
# resource "google_compute_instance_group_manager" "wk10_manage" {
#   name = "wk10-manage"

#   base_instance_name = "wk10"
#   zone  = "us-east1-b"


#   version {
#     instance_template  = google_compute_instance_template.wk10_template.self_link_unique
#   }

#   auto_healing_policies {
#     health_check      = google_compute_health_check.wk10_autohealing.id
#     initial_delay_sec = 300
#   }
# }
