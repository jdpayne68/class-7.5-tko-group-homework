resource "google_compute_instance" "wk8_vm" {
  name         = "wk8-vm"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = "100"
    }
  }


  network_interface {
    network = "default"

    access_config {}
  }

  tags = ["http-server"] #need for port 80 to open

  

  metadata_startup_script = file("./startup.sh") #very motivational
}

