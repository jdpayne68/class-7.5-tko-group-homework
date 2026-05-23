resource "google_compute_health_check" "wk9_autohealing" {
  name                = "wk9-health-check"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    # request_path = "/healthz"
    port         = "80"
  }
}

#for creating multiple zones
######################
# MIG Multiply Zone 
######################
resource "google_compute_region_instance_group_manager" "wk9_primary" {
  name = "wk9-manage"

  base_instance_name = "wk9"
  region                     = "us-east1"
  distribution_policy_zones  = ["us-east1-b", "us-east1-c", "us-east1-d"]

  version {
    instance_template  = google_compute_instance_template.wk9_clone.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.wk9_autohealing.id
    initial_delay_sec = 300
  }
}


# for creating single zone
####################
# MIG Single Zone
####################
# resource "google_compute_instance_group_manager" "wk9_wk9_primary" {
#   name = "wk9-manage"

#   base_instance_name = "wk9"
#   zone  = "us-east1-b"
 

#   version {
#     instance_template  = google_compute_instance_template.wk9_clone.self_link_unique
#   }

#   auto_healing_policies {
#     health_check      = google_compute_health_check.wk9_autohealing.id
#     initial_delay_sec = 300
#   }
# }
