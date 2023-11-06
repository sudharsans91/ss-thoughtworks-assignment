# General variables
variable "location" {
  description = "The resource group location"
  default     = "Central Us"
}
# Hub variables
variable "spoke_resource_group_name" {
  description = "The resource group name to be created"
  default     = ""
}
# Terraform State Storage Account variables
variable "backendAzureRmResourceGroupName" {
  description = "backendAzureRmResourceGroupName"
  type        = string
}
variable "backendAzureRmStorageAccountName" {
  description = "backendAzureRmStorageAccountName"
  type        = string
}
variable "backendAzureRmContainerName" {
  description = "backendAzureRmContainerName"
  type        = string
}
variable "backendAzureRmKey" {
  description = "backendAzureRmKey"
  type        = string
}

variable "rt_name" { }
variable "r_name" { }
variable "log_analytics_workspace_name" { }
variable "log_analytics_workspace_sku" { }
variable "aks_name" { }
variable "aks_version" { }
variable "aks_sku_tier" { }
variable "max_count" { }
variable "min_count" { }
variable "max_pods" { }
variable "os_disk_size_gb" { }
variable "nodepool_vm_size" { }
variable "os_disk_type" { }
variable "nodepool_vm_size" { }
variable "network_docker_bridge_cidr" { }
variable "network_dns_service_ip" { }
variable "network_service_cidr" { }
