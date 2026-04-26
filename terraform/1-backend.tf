#The GCS backend bucket must be created first, 
#before terraform init, because Terraform cannot use a backend that does not already exist.

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "shadowcat"
    prefix = "terraform/state"
  }
}


resource "google_compute_disk" "grafana_disk" {
  #depends_on = [terraform_data.preflight_gate]
  name = "grafana-disk"
  type = "pd-standard"
  zone = "us-central1-a"
  size = 10
}
