# ----------------------------------------------------------------
# Terraform Configuration
# ----------------------------------------------------------------

# Terraform Provider - Google
# https://registry.terraform.io/providers/hashicorp/google/latest
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}