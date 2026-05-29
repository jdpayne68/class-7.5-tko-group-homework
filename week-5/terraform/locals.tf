# ================================================================
# LOCALS
# ================================================================

locals {
  name_prefix   = "${var.app}-${var.env}"
  name_suffix   = lower(random_string.suffix.result)
  bucket_suffix = random_id.object_storage_suffix.hex
}
