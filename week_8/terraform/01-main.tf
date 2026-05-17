# Terraform configuration block - defines version requirements
terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
# Provider block - tells Terraform which GCP project and region to use
provider "google" {
  project = var.project_id
  region  = var.region
}
# VM resource - provisions a CentOS Stream 10 VM in the default VPC
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # Boot disk - 100GB CentOS Stream 10
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100
    }
  }

  # Network - default VPC with external IP
  network_interface {
    network = "default"

    access_config {
      # Ephemeral external IP
    }
  }

  # Tags - opens port 80 via default VPC firewall rule
  tags = ["http-server"]

  # Startup script - installs Apache and displays VM metadata
  metadata_startup_script = file("startup.sh")
}