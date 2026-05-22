terraform {
  required_version = ">= 1.10"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.33.0" #current version as of 5/20/2026
    }
  }
}

provider "google" {
  project = "project8338-490201"
  region  = var.region
}