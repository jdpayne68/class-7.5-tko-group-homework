# ----------------------------------------------------------------
# OUTPUTS
# ----------------------------------------------------------------

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.dev_sandbox.name
}