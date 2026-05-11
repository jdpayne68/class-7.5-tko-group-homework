# ----------------------------------------------------------------
# Terraform Backend Configuration (GCS)
# ----------------------------------------------------------------

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "kirkdevsecops-terraform-state"
    prefix = "week-7-static-website/dev"
  }
}