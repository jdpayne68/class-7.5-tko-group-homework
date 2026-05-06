output "bucket_name" {
  value = google_storage_bucket.antman_terraform.name
}

output "bucket_url" {
  value = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.antman_terraform.name}"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.antman_terraform.name}/index.html"
}

