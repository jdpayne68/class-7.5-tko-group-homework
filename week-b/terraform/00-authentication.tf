# ----------------------------------------------------------------
# Terraform Configuration
# ----------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}

# resource "null_resource" "check_ansible" {
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "ansible --version"
#   }
# }