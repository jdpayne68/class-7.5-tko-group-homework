# ----------------------------------------------------------------
# RUNTIME - GKE CREDENTIALS FETCH
# ----------------------------------------------------------------
# This runs locally after cluster creation to configure kubectl.
# NOTE:
# - Uses gcloud CLI (must be installed + authenticated)
# - Runs on EVERY apply (intentional for lab via timestamp trigger)
# ----------------------------------------------------------------

resource "null_resource" "gke_get_credentials" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials dev-main-cluster --zone us-central1-a --project kirk-devsecops-sandbox"
  }

  depends_on = [
    google_container_cluster.dev_main_cluster
  ]
}