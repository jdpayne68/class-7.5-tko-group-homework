# ----------------------------------------------------------------
# SERVICE ACCOUNTS - IDENTITY LAYER
# ----------------------------------------------------------------
variable "billing_account_id" {
  description = "The Google Cloud Billing Account ID used by the VM dashboard."
  default     = "01BB2F-8195CD-645BC0"
  type        = string
}

variable "app" {
  type        = string
  description = "Application name used for unique resource name prefixes."
  default     = "c7-5-week-5"
}

variable "env" {
  type        = string
  description = "Environment name used for unique resource name prefixes."
  default     = "dev"
}
