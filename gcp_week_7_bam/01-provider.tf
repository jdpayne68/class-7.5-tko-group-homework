terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.29.0" 
    }
  }
}

provider "google" {
  project = "project8338-490201"
  region  = "us-central1"
}


