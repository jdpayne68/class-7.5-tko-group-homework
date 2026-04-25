# ----------------------------------------------------------------
# SERVICE ACCOUNTS - IDENTITY LAYER
# ----------------------------------------------------------------
variable "billing_account_id" {
  description = "The Google Cloud Billing Account ID used by the VM dashboard."
  default = "01BB2F-8195CD-645BC0"
  type        = string
}
