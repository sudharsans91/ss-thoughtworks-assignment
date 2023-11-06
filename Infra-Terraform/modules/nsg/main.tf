/*
resource "azurerm_network_security_group" "nsg02" {
	name                    = "${var.app_prefix}-nsg-firewall_subnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso02" {
	subnet_id                   = var.subnet_id02
	network_security_group_id   = azurerm_network_security_group.nsg02.id
}
*/
/*
resource "azurerm_network_security_group" "nsg01" {
	name                    = "${var.app_prefix}-nsg-AzureBastionSubnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso01" {
	subnet_id                   = var.subnet_id01
	network_security_group_id   = azurerm_network_security_group.nsg01.id
}
*/

resource "azurerm_network_security_group" "nsg04" {
	name                    = "${var.app_prefix}-nsg-aks-subnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso04" {
	subnet_id                   = var.subnet_id04
	network_security_group_id   = azurerm_network_security_group.nsg04.id
}

resource "azurerm_network_security_group" "nsg05" {
	name                    = "${var.app_prefix}-nsg-jumpbox-subnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso05" {
	subnet_id                   = var.subnet_id05
	network_security_group_id   = azurerm_network_security_group.nsg05.id
}
/*
resource "azurerm_network_security_group" "nsg06" {
	name                    = "${var.app_prefix}-nsg-data-subnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name2
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso06" {
	subnet_id                   = var.subnet_id06
	network_security_group_id   = azurerm_network_security_group.nsg06.id
}
*/
/*
resource "azurerm_network_security_group" "nsg07" {
	name                    = "${var.app_prefix}-nsg-ingress-subnet-${var.subscription_suffix}"
	resource_group_name     = var.resource_group_name2
	location                = var.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-asso07" {
	subnet_id                   = var.subnet_id07
	network_security_group_id   = azurerm_network_security_group.nsg07.id
}
*/