resource "random_id" "suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "kubeworkspace" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "ContainerInsights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group
  workspace_resource_id = azurerm_log_analytics_workspace.kubeworkspace.id
  workspace_name        = azurerm_log_analytics_workspace.kubeworkspace.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}