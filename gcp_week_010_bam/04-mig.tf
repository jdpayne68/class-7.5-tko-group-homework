resource "google_compute_health_check" "eta" {
  name                = "${local.name_prefix}-health-check"
  check_interval_sec  = 10
  timeout_sec         = 10
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
resource "google_compute_region_instance_group_manager" "gamma" {
  name = "${local.name_prefix}-gamma"

  base_instance_name        = "wk10"
  region                    = var.region
  distribution_policy_zones = ["${var.region}-b", "${var.region}-c", "${var.region}-d"]

  version {
    instance_template = google_compute_instance_template.delta.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.eta.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_instance_group_manager" "omicron" {
  name = "${local.name_prefix}-omicron"

  base_instance_name        = "wk10"
  region                    = var.region
  distribution_policy_zones = ["${var.region}-b", "${var.region}-c", "${var.region}-d"]

  version {
    instance_template = google_compute_instance_template.delta.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.eta.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_instance_group_manager" "psi" {
  name = "${local.name_prefix}-psi"

  base_instance_name        = "wk10"
  region                    = var.region
  distribution_policy_zones = ["${var.region}-b", "${var.region}-c", "${var.region}-d"]

  version {
    instance_template = google_compute_instance_template.delta.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.eta.id
    initial_delay_sec = 300
  }
}

# for creating single zone
####################
# MIG Single Zone
####################
# resource "google_compute_instance_group_manager" "gamma" {
#   name = "${local.name_prefix}-manage"

#   base_instance_name = "wk10"
#   zone  = "us-east1-b"


#   version {
#     instance_template  = google_compute_instance_template.beta.self_link_unique
#   }

#   auto_healing_policies {
#     health_check      = google_compute_health_check.eta.id
#     initial_delay_sec = 300
#   }
# }


###############
#AutoScaler
###############


# for multi zone MIG
########################
# Multi Zone Autoscaler
########################
resource "google_compute_region_autoscaler" "gamma_s" {
  name   = "${local.name_prefix}-wk10gamma"
  region = var.region
  target = google_compute_region_instance_group_manager.gamma.id


  autoscaling_policy {
    max_replicas    = 9
    min_replicas    = 3
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_region_autoscaler" "omicron_s" {
  name   = "${local.name_prefix}-wk10omicron"
  region = var.region
  target = google_compute_region_instance_group_manager.omicron.id


  autoscaling_policy {
    max_replicas    = 9
    min_replicas    = 3
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_region_autoscaler" "psi_s" {
  name   = "${local.name_prefix}-wk10psi"
  region = var.region
  target = google_compute_region_instance_group_manager.psi.id


  autoscaling_policy {
    max_replicas    = 9
    min_replicas    = 3
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

# for single zone MIG
###########################
# Single Zone Autoscaler
###########################
# resource "google_compute_autoscaler" "wk10_link" {
#   name   = "${local.name_prefix}-autoscale"
#   zone   = var.region-b
#   target = google_compute_instance_group_manager.wk10_overseer.id


#   autoscaling_policy {
#     max_replicas    = 9
#     min_replicas    = 3
#     cooldown_period = 60

#     cpu_utilization {
#       target = 0.6
#     }
#   }
# }
