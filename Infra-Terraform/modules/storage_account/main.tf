resource "azurerm_storage_account" "sa" {
  name                      = var.sa_name
  resource_group_name       = var.resource_group
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = var.sc_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "sb" {
  name                   = var.sc_name
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
}

module "private_endpoint" {
  source                     = "../private_endpoint"
  resource_group             = var.spoke_rg_name
  private_endpoint_name      = var.pe_sa_name
  location                   = var.location
  private_endpoint_subnet_id = var.spoke_network_pep_subnet
  instance_name              = azurerm_storage_account.sa.name
  private_link_id            = azurerm_storage_account.sa.id
  subresource_names          = ["blob"]
  private_dns_zone_id        = var.private_dns_zone_id
}
