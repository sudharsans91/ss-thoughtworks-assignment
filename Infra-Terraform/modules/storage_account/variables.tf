variable "resource_group" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location where storage account will be deployed"
  type        = string
}

variable "sa_name" {
  description = "Storage account name"
  type        = string
}

variable "sc_name" {
  description = "storage container name"
  type        = string
}

variable "sb_name" {
  description = "storage blob name"
  type        = string
}


variable "spoke_network_pep_subnet" {
  description = "Private endpoint subnet ID"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}

variable "pe_sa_name" {
  description = "Private endpoint name"
  type        = string
}

variable "spoke_rg_name" {
  description = "spoke resource group name"
  type        = string
}
