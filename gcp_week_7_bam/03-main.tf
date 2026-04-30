resource "google_storage_bucket" "gcswk7" {
  name          = "gcswk7"
  location      = "us-central1"
  storage_class = "STANDARD"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page = "404.html"
  }
}


resource "google_storage_bucket_object" "index" {
    name = "index.html"
    bucket = google_storage_bucket.gcswk7.name
    source = "index.html"
}

resource "google_storage_bucket_object" "error" {
    # names must start with a letter or underscore
    name = "error.html"
    bucket = google_storage_bucket.gcswk7.name
    source = "404.html"
}

resource "google_storage_bucket_object" "style" {
    name = "style.css"
    bucket = google_storage_bucket.gcswk7.name
    source = "style.css"
}

resource "google_storage_bucket_object" "mines" {
    name = "mines.png"
    bucket = google_storage_bucket.gcswk7.name
    source = "mines.png"
}


data "google_iam_policy" "objectViewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allUsers",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "wk7policy" {
  bucket = google_storage_bucket.gcswk7.name
  policy_data = data.google_iam_policy.objectViewer.policy_data
  timeouts {
    # timeout configuration
    create = "5m"
  }
}