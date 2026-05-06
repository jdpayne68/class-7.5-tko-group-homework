terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.29.0"
    }
  }
}

provider "google" {
  project = "saba-seir"
  region  = "us-central1"
  zone    = "us-central1-c"
}

#Local file with favorite food created
resource "local_file" "cautchy-fav-food" {
  content  = "attieke-choukouya"
  filename = "${path.module}/cautchy-fav-food.txt"
}