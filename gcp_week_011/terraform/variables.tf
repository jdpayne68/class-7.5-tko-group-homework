variable "region" {
  description = "the region for the project"
  default     = "us-east1"
  type        = string

}


variable "machine_type" {
  description = "the machine type to create"
  default     = "e2-medium"
  type        = string

}