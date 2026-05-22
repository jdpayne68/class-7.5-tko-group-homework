terraform {
  required_version = ">= 1.10"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.31.0" #current version as of 5/7/2026
    }
  }
}

provider "google" {
  project = "project8338-490201"
  region  = "us-central1"
}