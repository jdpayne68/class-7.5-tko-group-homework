# for multi zone MIG
########################
# Multi Zone Autoscaler
########################
resource "google_compute_region_autoscaler" "wk10_link" {
  name   = "${local.name_prefix}-autoscale"
  region = var.region
  target = google_compute_region_instance_group_manager.wk10_overseer.id


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
