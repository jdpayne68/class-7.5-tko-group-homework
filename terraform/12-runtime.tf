resource "null_resource" "get_credentials" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials primary --zone us-central1-a --project theo-class-7-5"
  }

  depends_on = [
    google_container_cluster.primary
  ]
}


output "kubectl_command" {
  value = "kubectl get nodes"
}

output "gke_get_credentials" {
  value = "gcloud container clusters get-credentials primary --zone us-central1-a --project theo-class-7-5"
}
