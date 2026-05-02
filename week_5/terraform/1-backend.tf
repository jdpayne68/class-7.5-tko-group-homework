# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "illinitf-marvin-evins-2026"
    prefix = "terraform/state"
  }
}


# Create a persistent disk for Grafana to use for storage
# we need a persistent disk so that Grafana can store its data even if the pod is restarted
# grafana is a service that needs persistent storage to keep its data across restarts
# what is grafana_disk? it is a google compute disk resource that will be used by grafana to store its data persistently
resource "google_compute_disk" "grafana_disk2" {
  #depends_on = [terraform_data.preflight_gate]
  name  = "grafana-disk2"
  type  = "pd-standard"
  zone  = "us-central1-a"
  size  = 10
}