resource "google_service_account" "gsa_service_a" {
  project      = "theo-class-7-5"
  account_id   = "service-a"
  display_name = "Service Account for Kubernetes"
}

resource "google_project_iam_member" "service_a_storage_admin" {
  project = "theo-class-7-5"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gsa_service_a.email}"
}

resource "google_service_account_iam_member" "service_a_workload_identity" {
  service_account_id = google_service_account.gsa_service_a.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:theo-class-7-5.svc.id.goog[staging/service-a]"
}
