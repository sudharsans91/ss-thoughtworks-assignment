## Azure Virtual Network  

Creates two Azure Virtual Networks and manages the address space and subnets

# Example 

```
module "hub_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = var.hub_address_space
  subnets             = var.hub_subnets
}

module "spoke_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = var.location
  vnet_name           = var.spoke_vnet_name
  address_space       = var.spoke_address_space
  subnets             = var.spoke_subnets
}
```

### Inputs for VNET Module  

|      Name    |   Description    |    Type   |     Default    |    Required   |
|--------------|------------------|-----------|----------------|---------------|
|resource_group_name        |The name of the resource group    |	string   |	n/a	    | yes
|location                   |The location/region where the virtual network is created | string | n/a | yes 
|vnet_name                  |The name of the virtual network | string  	 |  n/a  	|yes
|address_space      	    |The address space that is used in the virtual network |list(string)| [] | yes
|subnets                    |The subnet range  | list(object)    |	n/a	    |yes