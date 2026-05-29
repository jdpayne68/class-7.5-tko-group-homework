# ================================================================
# TERRAFORM PROVIDERS
# ================================================================

# ----------------------------------------------------------------
# Required Providers
# ----------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33"
      # Documentation - Google Provider
      # https://registry.terraform.io/providers/hashicorp/google/latest

    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
      # Documentation - Random Provider
      # https://registry.terraform.io/providers/hashicorp/random/latest
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
      # Documentation - Local Provider
      # https://registry.terraform.io/providers/hashicorp/local/latest
    }
  }
}

# ----------------------------------------------------------------
# Provider Configurations
# ----------------------------------------------------------------
provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}

provider "random" {
  # no config needed
}

provider "local" {
  # no config needed
}