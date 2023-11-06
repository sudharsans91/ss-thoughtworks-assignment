variable "resource_group" {
  description = "Resource group name"
  type        = string
}
variable "keyvault_name" {
  description = "Key Vault name"
  type        = string
}

variable "location" {
  description = "Location where key vault will be deployed"
  type        = string
}

variable "hub_network_pep_subnet" {
  description = "Private endpoint subnet ID"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}

variable "pe_kv_name" {
  description = "Private endpoint name"
  type        = string
}

variable "hub_rg_name" {
  description = "spoke resource group name"
  type        = string
}