#autoscaling for the instance group manager
resource "google_compute_region_autoscaler" "instance_group_manager_autoscaler" {
  name   = "wk-9-instance-group-manager-autoscaler"
  region = var.region
  target = google_compute_instance_group_manager.wk-9-instance-group-manager.id

  autoscaling_policy {
    max_replicas = 5 # this is the maximum number of instances that the autoscaler will create. You can adjust this based on your requirements.
    min_replicas = 1 # this is the minimum number of instances that the autoscaler will maintain. You can adjust this based on your requirements.
    cpu_utilization {
      target = 0.6 # this means that the autoscaler will try to maintain an average CPU utilization of 60% across all instances in the instance group. If the CPU utilization exceeds this threshold, the autoscaler will create new instances to handle the load. If the CPU utilization falls below this threshold, the autoscaler will remove instances to save costs.
    }
    cooldown_period = 60 # this is the amount of time (in seconds) that the autoscaler will wait before it starts to scale up or down again after it has already scaled up or down. This helps to prevent rapid scaling actions that can occur due to temporary spikes in traffic or load. You can adjust this based on your requirements.


  }
}
