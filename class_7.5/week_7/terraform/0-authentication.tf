terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.30.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "training-416401"
  region  = "us-central1"
}
