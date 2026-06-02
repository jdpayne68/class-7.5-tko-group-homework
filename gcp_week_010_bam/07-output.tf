output "lb_ip" {
  value = "http://${google_compute_global_address.phi.address}"
}

# output "domain" {
#   value = "https://${data.google_compute_ssl_certificate.nwo.id}"
# }