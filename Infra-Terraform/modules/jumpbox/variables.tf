variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "jumpbox_vm_name" {
  description = "VM and computer hostname of Jumpbox"
}

variable "jumpbox_vm_size" {
  description = "VM size"
}

variable "subnet_id" {
  description = "ID of subnet where jumpbox VM will be installed"
  type        = string
}

variable "dns_zone_name" {
  description = "Private DNS Zone name to link the jumpbox's vnet"
  type        = string
}

variable "dns_zone_resource_group" {
  description = "Private DNS Zone resource group"
  type        = string
}

variable "vm_user" {
  description = "Jumpbox VM user name"
  type        = string
  default     = "azureuser"
}

variable "vnet_id" {
  description = "ID of the VNET where jumpbox VM will be installed"
  type        = string
}
