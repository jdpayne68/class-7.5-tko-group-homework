# ----------------------------------------------------------------
# PROJECT SERVICES — ENABLE REQUIRED APIS
# ----------------------------------------------------------------
# Enables required GCP APIs via google_project_service resources

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}