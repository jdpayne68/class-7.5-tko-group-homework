# ================================================================
# NAMING HELPERS
# ================================================================

resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "random_id" "object_storage_suffix" {
  byte_length = 4
}
