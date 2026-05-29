# ================================================================
# BACKEND
# ================================================================

# ----------------------------------------------------------------
# Terraform Backend Configuration - Google (GCS)
# ----------------------------------------------------------------
# Documentation - GCS Backend
# https://www.terraform.io/language/settings/backends/gcs

terraform {
  backend "gcs" {
    bucket = "kirkdevsecops-terraform-state"
    prefix = "week-8-homework/dev"
  }
}