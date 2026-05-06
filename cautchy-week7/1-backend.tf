# Remote GCS Backend using the sabatf bucket already provisioned for class (storing the tfstate file)
terraform {
  backend "gcs" {
    bucket = "saba-terra"
    prefix = "terraform/state"
  }

}