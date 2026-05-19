# autohealing for the instance group manager
resource "google_compute_health_check" "week-9-autohealing" {
  name               = "wk-9-instance-group-manager-autohealing"
  check_interval_sec = 5 # this is the interval (in seconds) between health checks. You can adjust this based on your requirements.
  timeout_sec        = 5 # this is the amount of time (in seconds) that the health check will wait for a response before it considers the instance to be unhealthy. You can adjust this based on your requirements.
  healthy_threshold   = 2 # this is the number of consecutive successful health checks that an instance must pass before it is considered healthy. You can adjust this based on your requirements.
  unhealthy_threshold = 2 # this is the number of consecutive failed health checks that an instance must fail before it is considered unhealthy. You can adjust this based on your requirements.
  
  http_health_check {
    port = "8080" 
    request_path = "/healthz" 
  }
}







## multiple zones
resource "google_compute_region_instance_group_manager" "wk-9-instance-group-manager" {
  name               = "wk-9-instance-group-manager"
  base_instance_name = "wk-9-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.instance_template.self_link
  }

  target_size = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.week-9-autohealing.self_link
    initial_delay_sec = 300
  }
}