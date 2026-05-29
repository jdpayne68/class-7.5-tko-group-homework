# ----------------------------------------------------------------
# VPC
# ----------------------------------------------------------------

resource "google_compute_network" "dev_sandbox" {
  name = "${local.name_prefix}-sandbox"
}