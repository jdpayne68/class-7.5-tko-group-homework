# ----------------------------------------------------------------
# SERVICE ACCOUNTS - IDENTITY LAYER
# ----------------------------------------------------------------
# REMEMBER:
# Service Accounts = WHO you are
# IAM Roles        = WHAT you can do

# ----------------------------------------------------------------
# SERVICE ACCOUNT - VM DASHBOARD
# ----------------------------------------------------------------
resource "google_service_account" "vm_dashboard" {
  project      = "kirk-devsecops-sandbox"
  account_id   = "vm-dashboard"
  display_name = "VM Dashboard Service Account"
}

# ----------------------------------------------------------------
# IAM ROLES - VM DASHBOARD PROJECT PERMISSIONS
# ----------------------------------------------------------------
# These roles allow the dashboard VM to read:
# - BigQuery billing export data
# - Cloud Monitoring metrics
# - Recommender insights and recommendations
#
# Keep these read-only where possible.
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# IAM ROLE - BIGQUERY DATA VIEWER
# ----------------------------------------------------------------
# Allows the VM dashboard to read billing export tables.
# Required for actual cost data.
# ----------------------------------------------------------------

resource "google_project_iam_member" "vm_dashboard_bigquery_data_viewer" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/bigquery.dataViewer"

  member = "serviceAccount:${google_service_account.vm_dashboard.email}"
}

# ----------------------------------------------------------------
# IAM ROLE - BIGQUERY JOB USER
# ----------------------------------------------------------------
# Allows the VM dashboard to run BigQuery jobs.
# Required to query billing export data.
# ----------------------------------------------------------------

resource "google_project_iam_member" "vm_dashboard_bigquery_job_user" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/bigquery.jobUser"

  member = "serviceAccount:${google_service_account.vm_dashboard.email}"
}

# ----------------------------------------------------------------
# IAM ROLE - MONITORING VIEWER
# ----------------------------------------------------------------
# Allows the VM dashboard to read Cloud Monitoring metrics.
# Required for utilization data like CPU, memory, and resource metrics.
# ----------------------------------------------------------------

resource "google_project_iam_member" "vm_dashboard_monitoring_viewer" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/monitoring.viewer"

  member = "serviceAccount:${google_service_account.vm_dashboard.email}"
}

# ----------------------------------------------------------------
# IAM ROLE - RECOMMENDER VIEWER
# ----------------------------------------------------------------
# Allows the VM dashboard to read recommender insights.
# Required for rightsizing and savings recommendations.
# ----------------------------------------------------------------

resource "google_project_iam_member" "vm_dashboard_recommender_viewer" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/recommender.viewer"

  member = "serviceAccount:${google_service_account.vm_dashboard.email}"
}

# ----------------------------------------------------------------
# IAM ROLE - BILLING VIEWER
# ----------------------------------------------------------------
# Grants read-only access to the billing account.
#
# Required for:
# - Billing account metadata
# - Budget definitions
# - Budget thresholds
# - Budget read access through the Budgets API
#
# IMPORTANT:
# There is no separate budget viewer role needed for read-only dashboards.
# roles/billing.viewer includes budget read permissions.
#
# Replace var.billing_account_id with your billing account ID variable,
# or hardcode the billing account ID if that is how your Terraform is set up.
# ----------------------------------------------------------------

resource "google_billing_account_iam_member" "vm_dashboard_billing_viewer" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"

  member = "serviceAccount:${google_service_account.vm_dashboard.email}"
}






# ----------------------------------------------------------------
# SERVICE ACCOUNT - KUBERNETES NODES (INFRASTRUCTURE IDENTITY)
# ----------------------------------------------------------------
# Used by GKE node VMs
# Allows nodes to interact with GCP (logging, pulling images, etc.)
#
# IMPORTANT:
# This is NOT used directly by pods (unless Workload Identity is NOT configured)
# Keep permissions minimal (principle of least privilege)
# ----------------------------------------------------------------

resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes"
  display_name = "Kubernetes Node Service Account"
}

# ----------------------------------------------------------------
# SERVICE ACCOUNT - WORKLOAD (POD IDENTITY)
# ----------------------------------------------------------------
# Used by: Kubernetes ServiceAccount: staging/service-a
# Represents the identity of a specific workload when calling GCP APIs
#
# Naming: account_id matches KSA name for easier mental mapping
# Flow: Pod → KSA (service-a) → GSA (service-a) → IAM roles
# ----------------------------------------------------------------

resource "google_service_account" "gsa_service_a" {
  project      = "kirk-devsecops-sandbox"
  account_id   = "service-a" # <-- choose your identity name here
  display_name = "GSA for KSA staging/service-a"
}

# ----------------------------------------------------------------
# IAM ROLES
# ----------------------------------------------------------------
# IMPORTANT: Roles are attached to GSAs (not KSAs)
# Keep roles as narrow as possible (tighten later)


# ----------------------------------------------------------------
# IAM ROLE - STORAGE ADMIN (WORKLOAD PERMISSIONS)
# ----------------------------------------------------------------
# Grants full access to Cloud Storage (broad, but good for practice)
# Applies to GSA: service-a
# Replace later with narrower roles (objectViewer, objectAdmin, etc.)
# ----------------------------------------------------------------

resource "google_project_iam_member" "service_a_storage_admin" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/storage.admin"

  member = "serviceAccount:${google_service_account.gsa_service_a.email}"
}

# ----------------------------------------------------------------
# WORKLOAD IDENTITY - TRUST BINDING (KSA ↔ GSA)
# ----------------------------------------------------------------
# The CRITICAL bridge between:
# Kubernetes identity (KSA)
# Google Cloud identity (GSA)
#
# Without this, pods cannot assume the GSA identity
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# WORKLOAD IDENTITY BINDING
# ----------------------------------------------------------------
# Allows KSA: staging/service-ato impersonate:
# GSA: service-a@kirk-devsecops-sandbox
#
# IMPORTANT:
# Uses CLUSTER PROJECT (not resource project)
# 
# Format:
# serviceAccount:<PROJECT>.svc.id.goog[NAMESPACE/KSA_NAME]
#
# Common failure point:
# - Wrong project in member string
# - Namespace mismatch
# - KSA name mismatch
# ----------------------------------------------------------------

resource "google_service_account_iam_member" "service_a_workload_identity" {
  service_account_id = google_service_account.gsa_service_a.id
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:kirk-devsecops-sandbox.svc.id.goog[staging/service-a]"
}