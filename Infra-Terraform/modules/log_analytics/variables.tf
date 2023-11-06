variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace Name"
  type        = string
}
variable "resource_group" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}