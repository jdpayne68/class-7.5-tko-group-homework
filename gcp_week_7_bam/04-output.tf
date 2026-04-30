output "website_url" {
    description = "Public URL for the static website index page"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/index.html"
}

output "website_url_1" {
    description = "Public URL for the static website error page"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/error.html"
}

output "style_css" {
    description = "Public URL for css styling"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/style.css"
}

output "website_image" {
    description = "Public URL for the static website image page"
    value = "https://storage.googleapis.com/${google_storage_bucket.gcswk7.name}/mines.png"
}