# Create new storage bucket in the US
# location with Standard Storage

resource "google_storage_bucket" "antman_terraform" {
  name          = "antman-terraform"
  location      = "US"
  storage_class = "STANDARD"
  force_destroy = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Make bucket publicly accessible
resource "google_storage_bucket_iam_member" "public_access_rule" {
  bucket = google_storage_bucket.antman_terraform.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

####################################################################
# Upload a text file as an object
# to the storage bucket
####################################################################

#Cautchy-fav-food.txt file upload
resource "google_storage_bucket_object" "cautchy_fav-food_txt" {
  name         = "cautchy-fav-food.txt"
  source       = "./cautchy-fav-food.txt"
  content_type = "text/plain"
  bucket       = google_storage_bucket.antman_terraform.id
}

#fifa_wc.jpg file upload
resource "google_storage_bucket_object" "fifa-wc_jpg" {
  name         = "fifa_wc.jpg"
  source       = "./fifa_wc.jpg"
  content_type = "image/jpeg"
  bucket       = google_storage_bucket.antman_terraform.id
}

#index.html file upload
resource "google_storage_bucket_object" "index_html" {
  name         = "index.html"
  source       = "./index.html"
  content_type = "text/html"
  bucket       = google_storage_bucket.antman_terraform.id
}

#404.html file upload
resource "google_storage_bucket_object" "_404_html" {
  name         = "404.html"
  source       = "./404.html"
  content_type = "text/html"
  bucket       = google_storage_bucket.antman_terraform.id
}

##style.css file upload
resource "google_storage_bucket_object" "style_css" {
  name         = "style.css"
  source       = "./style.css"
  content_type = "text/css"
  bucket       = google_storage_bucket.antman_terraform.id
}