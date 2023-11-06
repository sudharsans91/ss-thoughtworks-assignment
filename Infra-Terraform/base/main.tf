terraform {
  required_version = ">= 0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.57.0"
    }
  }

  backend "azurerm" {
# TEAM: Updated to use my storage for testing init & plan

    resource_group_name  = var.backendAzureRmResourceGroupName
    storage_account_name = var.backendAzureRmStorageAccountName
    container_name       = var.backendAzureRmContainerName
    key                  = var.backendAzureRmKey
  }
}

data "azurerm_subscription" "primary" {
}


provider "azurerm" {
  features {}
}

provider "random" {
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  lower   = false
}

#############################################
# Resource Groups
#############################################

resource "azurerm_resource_group" "spoke" {
  name     = var.spoke_resource_group_name
  location = var.location
}

module "spoke_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = var.location
  vnet_name           = var.spoke_vnet_name
  address_space       = var.spoke_address_space
  subnets             = var.spoke_subnets
}

module "routetable" {
  source             = "./modules/route_table"
  resource_group     = azurerm_resource_group.spoke.name
  location           = var.location
  rt_name            = var.rt_name
  r_name             = var.r_name
  fw_private_ip      = module.firewall.fw_private_ip
  subnet_id          = module.spoke_network.subnet_ids["aks-subnet"]
}

module "log_analytics" {
  source                       = "./modules/log_analytics"
  resource_group               = azurerm_resource_group.spoke.name
  location                     = var.location
  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_analytics_workspace_sku  = var.log_analytics_workspace_sku
}

module "application_gateway" {
  source                   = "./modules/application_gateway"
  resource_group           = azurerm_resource_group.spoke.name
  location                 = var.location
  application_gateway_name = var.application_gateway_name
  application_gateway_sku  = var.application_gateway_sku
  application_gateway_tier = var.application_gateway_tier
  subnet_id                = module.spoke_network.subnet_ids["ingress-subnet"]
  private_ip_address       = var.application_gateway_private_ip
  waf_policy_id            = module.waf_policy.id      
  depends_on = [
    module.spoke_network
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  dns_prefix              = "${var.aks_name}-dns"
  kubernetes_version      = var.aks_version
  location                = var.location
  name                    = var.aks_name
  private_cluster_enabled = true
  resource_group_name     = azurerm_resource_group.spoke.name
  node_resource_group     = "${azurerm_resource_group.spoke.name}-aks"
  sku_tier                = var.aks_sku_tier

  addon_profile {
    azure_policy {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = module.log_analytics.id
    }
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = false
    }
  }

  default_node_pool {
    availability_zones  = [ "1", "2", "3" ]
    enable_auto_scaling = true
    max_count           = var.max_count
    min_count           = var.min_count
    max_pods            = var.max_pods
    name                = "system"
    # node_count          = var.nodepool_nodes_count
    os_disk_size_gb     = lookup(var.os_disk_size_gb, var.nodepool_vm_size)
    os_disk_type        = lookup(var.os_disk_type, var.nodepool_vm_size)
    vm_size             = var.nodepool_vm_size
    vnet_subnet_id      = module.spoke_network.subnet_ids["aks-subnet"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      //admin_group_object_ids = [azuread_group.aksadministrators.id]
    }
  }

  depends_on = [
    module.routetable,
    module.log_analytics,
    module.firewall
  ]
}

# Assign the AKS cluster managed identity with "Network Contributor" role to AKS Subnet
resource "azurerm_role_assignment" "aksNetworkContributor" {
  principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = module.spoke_network.subnet_ids["aks-subnet"]
}

# Assign the AKS agent pool managed identity with "AcrPull" role to ACR
# Note: use the 'kubelet / agentpool' managed identity, not the AKS 
# cluster identity when using AKS managed identities
resource "azurerm_role_assignment" "aksAcrPull" {
  principal_id         = azurerm_kubernetes_cluster.privateaks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
  # principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.aks_name}-${random_string.random.result}"
  target_resource_id         = azurerm_kubernetes_cluster.privateaks.id
  log_analytics_workspace_id = module.log_analytics.id
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = false
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore this setting because Terraform detects changes on every run regardless of whether there are actual changes or not
      # and this could change outside of Terraform
      # lifecycle.ignore_changes skips operations during TF updates
      log
    ]
  }
}
module "kv" {
  source                 = "./modules/key_vault"
  location               = var.location
  keyvault_name          = "${var.keyvault_name}-${random_string.random.result}"
  resource_group         = azurerm_resource_group.spoke.name
  private_dns_zone_id    = azurerm_private_dns_zone.kv_private_zone.id
  spoke_network_pep_subnet = module.spoke_network.subnet_ids["jumpbox-subnet"]
  spoke_rg_name            = azurerm_resource_group.spoke.name
  pe_kv_name             = var.pe_kv_name
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.kv_zone_to_vnet_link,
    module.spoke_network
  ]
}
module "jumpbox" {
  source                  = "./modules/jumpbox"
  location                = var.location
  resource_group          = azurerm_resource_group.spoke.name
  jumpbox_vm_name         = "${var.jumpbox_vm_name}-vm"
  jumpbox_vm_size         = var.jumpbox_vm_size
  vnet_id                 = module.spoke_network.vnet_id
  subnet_id               = module.spoke_network.subnet_ids["jumpbox-subnet"]
  dns_zone_name           = join(".", slice(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn))))
  dns_zone_resource_group = azurerm_kubernetes_cluster.privateaks.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.privateaks,
  ]
}
resource "azurerm_role_assignment" "aksContributor" {
  principal_id         = module.jumpbox.jumpbox_identity
  role_definition_name = "Contributor"
  scope                = azurerm_kubernetes_cluster.privateaks.id
}
resource "azurerm_role_assignment" "jumpbox_User_Access_Admin" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "User Access Administrator"
  principal_id         = module.jumpbox.jumpbox_identity
}
module "storage_account" {
  source                   = "./modules/storage_account"
  resource_group           = azurerm_resource_group.spoke.name
  location                 = var.location
  spoke_network_pep_subnet = module.spoke_network.subnet_ids["data-subnet"]
  spoke_rg_name            = var.spoke_resource_group_name
  depends_on = [
    module.spoke_network
  ]
}

