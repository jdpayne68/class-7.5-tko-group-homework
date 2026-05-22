# for multi zone MIG
########################
# Multi Zone Autoscaler
########################
resource "google_compute_region_autoscaler" "wk9-auto" {
  name   = "wk9-autoscale"
  region = "us-east1"
  target = google_compute_region_instance_group_manager.wk9_manage.id


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
# resource "google_compute_autoscaler" "wk9-auto" {
#   name   = "wk9-autoscale"
#   zone   = "us-east1-b"
#   target = google_compute_instance_group_manager.wk9_manage.id


#   autoscaling_policy {
#     max_replicas    = 9
#     min_replicas    = 3
#     cooldown_period = 60

#     cpu_utilization {
#       target = 0.6
#     }
#   }
# }
