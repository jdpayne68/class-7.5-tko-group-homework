# ================================================================
# LOCALS
# ================================================================

locals {
  # -------------------------------------------------------------------
  # Core Account, Environment, and Naming Locals
  # -------------------------------------------------------------------

  # Environment setup
  env = lower(var.env)
  app = var.app

  # Naming helpers
  name_prefix   = "${local.app}-${local.env}"
  name_suffix   = lower(random_string.suffix.result)
  bucket_suffix = random_id.object_storage_suffix.hex
}