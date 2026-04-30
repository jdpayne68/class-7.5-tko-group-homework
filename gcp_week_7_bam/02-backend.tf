# the bucket for the backend needs to be made manually first for this to work
terraform {
  # backend is gcs
  backend "gcs" {
    bucket = "gcsweek7"
    prefix = "terraform/state"
  }
}

resource "google_compute_disk" "gcs7_disk" {
  name  = "gcs7-disk"
  type  = "pd-standard"
  zone  = "us-central1-a"
  size  = 10
}

