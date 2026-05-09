# Project variables - configure these for your environment
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "kamau-lab4-2026"
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
  default     = "us-east1-d"
}

variable "vm_name" {
  description = "The name of the VM instance"
  type        = string
  default     = "kamau-vm-week8"
}

variable "machine_type" {
  description = "The machine type for the VM - N series as required"
  type        = string
  default     = "n1-standard-1"
}