# create instance template
resource "google_compute_instance_template" "instance_template" {
    name         = "wk-9-instance-template"
    machine_type = "e2-medium" # this is a machine type that provides a balance of compute, memory, and network resources. It is suitable for a wide range of workloads, including web servers, small databases, and development environments.
    region      = var.region # this is the region where the instance template will be created. You can choose other regions based on your requirements.
    # specify the source image for the instance template
    disk {
        auto_delete = true
        boot        = true
        
        source_image = "debian-cloud/debian-12" # this is the latest Debian 12 image available in the Google Cloud Marketplace. You can choose other images based on your requirements.
        
    }
    
    # specify the network interface for the instance template
    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {
        // Ephemeral public IP will be assigned to the instance
        }
    }
    metadata_startup_script = file("startup-script.sh") 
    
    tags = ["http-server", "ssh-server"] # these tags will be used to allow traffic to the instances that have these tags in the firewall rules we created earlier.
    }