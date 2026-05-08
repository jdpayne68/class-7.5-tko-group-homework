# ----------------------------------------------------------------
# Terraform Configuration
# ----------------------------------------------------------------

terraform {
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = "~> 7.31.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
  }
}

provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}