data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "key_vault" {
  name                            = var.keyvault_name
  location                        = var.location
  resource_group_name             = var.resource_group
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  enable_rbac_authorization       = false
  enabled_for_template_deployment = true
  sku_name                        = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]
    storage_permissions = [
      "Backup",
      "Delete",
      "DeleteSAS",
      "Get",
      "GetSAS",
      "List",
      "ListSAS",
      "Purge",
      "Recover",
      "RegenerateKey",
      "Restore",
      "Set",
      "SetSAS",
      "Update"
    ]
  }
}

module "private_endpoint" {
  source                     = "../private_endpoint"
  resource_group             = var.hub_rg_name
  private_endpoint_name      = var.pe_kv_name
  location                   = var.location
  private_endpoint_subnet_id = var.hub_network_pep_subnet
  instance_name              = azurerm_key_vault.key_vault.name
  private_link_id            = azurerm_key_vault.key_vault.id
  subresource_names          = ["vault"]
  private_dns_zone_id        = var.private_dns_zone_id
}