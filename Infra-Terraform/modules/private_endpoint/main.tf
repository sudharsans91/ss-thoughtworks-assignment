resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_endpoint_subnet_id
  private_dns_zone_group {    
    name                 = "${var.private_endpoint_name}-group"    
    private_dns_zone_ids = [var.private_dns_zone_id]  
  }
  private_service_connection {
    name                           = "${var.private_endpoint_name}-psc"
    private_connection_resource_id = var.private_link_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }
}