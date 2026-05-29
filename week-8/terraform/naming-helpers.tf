# ================================================================
# NAMING HELPERS
# ================================================================
# Use naming helpers consistently to create unique resource names.

# ----------------------------------------------------------------
# Random String for Suffixes
# ----------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 5
  special = false
}

# ----------------------------------------------------------------
# Random Hex ID for Backend Resource Names
# ----------------------------------------------------------------

# Random Hex ID for backend resource names
resource "random_id" "object_storage_suffix" {
  byte_length = 4
}