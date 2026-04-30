#Resource via https://github.com/XDE77/SEIR-1/blob/main/weekly_lessons/weekb/terraform/8-outputs.tf

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.main.name
}
