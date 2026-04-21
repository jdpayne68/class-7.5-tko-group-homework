
#Chewbacca: The Force needs coordinates.
#You need this first in order to see if you can authenticate to GCP

#You need to change Project, Region, and Creds

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" 
    }
  }
}

provider "google" {
  project = "training-416401"
  region  = "us-central1"
#   credentials = file("C:\\Users\\marvi\\AppData\\Roaming\\gcloud\\application_default_credentials.json")
}