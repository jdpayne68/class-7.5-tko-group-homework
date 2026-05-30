resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Lab only

  depends_on = [
    google_compute_network.main
  ]
}

# This file defines a Google Cloud Firewall resource that will be used to allow incoming HTTP traffic to instances in the main subnet. The firewall rule will allow TCP traffic on port 80 from any source IP address, which is necessary for web servers that need to serve content over HTTP. The firewall rule will be associated with the main network and will ensure that instances in the main subnet can receive incoming HTTP traffic while still being protected by the firewall rules defined for the network.
resource "google_compute_firewall" "allow_http-main" {
  name    = "allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # this is a lab, in production you would want to limit this to specific IPs or ranges
  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}


# This file defines a Google Cloud Firewall resource that will be used to allow incoming HTTPS traffic to instances in the main subnet. The firewall rule will allow TCP traffic on port 443 from any source IP address, which is necessary for web servers that need to serve secure content over HTTPS. The firewall rule will be associated with the main network and will ensure that instances in the main subnet can receive incoming HTTPS traffic while still being protected by the firewall rules defined for the network.
resource "google_compute_firewall" "allow_https-main" {
  name    = "allow-https"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    #Lab only, in production you would want to limit this to specific IPs or ranges
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}

# port 500 udp
# port 500 is used for IKE (Internet Key Exchange) which is a protocol used to set up a secure and authenticated communication channel between two parties, typically for VPN (Virtual Private Network) connections. IKE is responsible for negotiating the security parameters and establishing the secure connection between the two parties. By allowing incoming UDP traffic on port 500, you are enabling the use of IKE for VPN connections, which can be important for secure remote access to resources in the network.
# in the real world, you would want to limit this to specific IPs or ranges, but for the purposes of this lab, we will allow it from any source IP address. This will allow us to test the VPN connection from any location without having to worry about IP restrictions. However, in a production environment, it is important to limit access to port 500 to only trusted IP addresses or ranges to prevent unauthorized access and potential security risks.
# ESP (Encapsulating Security Payload) is a protocol used in IPsec (Internet Protocol Security) to provide confidentiality, integrity, and authentication for network traffic. ESP is responsible for encrypting the payload of IP packets and providing authentication for the sender and receiver. By allowing incoming UDP traffic on port 500, you are enabling the use of IKE for VPN connections, which can be important for secure remote access to resources in the network. However, it is important to note that ESP does not use a specific port number like IKE does, as it operates at the IP layer and can be encapsulated within other protocols. Therefore, allowing UDP traffic on port 500 is necessary for IKE to function properly, but it does not directly affect ESP traffic.
resource "google_compute_firewall" "allow_udp-main" {
  name    = "allow-udp"
  network = google_compute_network.main.name

  allow {
    protocol = "udp"
    ports    = ["500"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}

#TCP 3389 RDP (Remote Desktop Protocol) is a proprietary protocol developed by Microsoft that allows users to remotely access and control a computer over a network connection. By allowing incoming TCP traffic on port 3389, you are enabling the use of RDP for remote desktop access to instances in the main subnet. This can be useful for administrators or users who need to manage or access resources in the network remotely. However, it is important to note that allowing RDP access from any source IP address can pose security risks, as it may allow unauthorized access to the instances. In a production environment, it is recommended to limit RDP access to specific IP addresses or ranges to enhance security and prevent potential unauthorized access.
resource "google_compute_firewall" "allow_rdp-main" {
  name    = "allow-rdp"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    google_compute_network.main
  ]
}