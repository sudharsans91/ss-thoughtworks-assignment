variable "private_endpoint_name" {
  description = "Private Endpoint Name"
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

variable "private_endpoint_subnet_id" {
  description = "Private Endpoint Subnet Id"
  type        = string
}

variable "private_link_id" {
  description = "Private Link Id"
  type        = string
}

variable "subresource_names" {
  description = "Subresource names"
  type        = list(string)
}

variable "instance_name" {
  description = "Name of the resource/instance the private endpoint is to be created for"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of private DNS Zone"
  type        = string
}