terraform {
      required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.26.0"
    }
  }
}

provider "google" {
  #The Force needs coordinates.
  project = var.project_id
  region  = var.region
  zone    = var.zone
}