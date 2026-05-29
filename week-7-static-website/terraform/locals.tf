# -----------------------------------------------------
# LOCALS 
# -----------------------------------------------------
locals {
  name_prefix   = "${var.app}-${var.env}"
  name_suffix   = lower(random_string.suffix.result)
  bucket_suffix = random_id.object_storage_suffix.hex

  # Website Source Code Files
  site_src = {
    "index.html" = {
      content_type = "text/html"
    }

    "404.html" = {
      content_type = "text/html"
    }

    "style.css" = {
      content_type = "text/css"
    }
  }

  # Website Assets - Beach Images
  beach_images = [
    "bali-indonesia.jpg",
    "fiji.jpg",
    "maldives.jpg",
    "sardinia-italy.jpg",
    "turks-and-caicos.jpg",
    "bora-bora-french-polynesia.jpg",
    "krabi-thailand.jpg",
    "maui-hawaii.jpg",
    "seychelles.jpg",
    "whitsunday-islands-australia.jpg"
  ]
}