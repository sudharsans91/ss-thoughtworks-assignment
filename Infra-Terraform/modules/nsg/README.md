## Network Security Groups 

The Network Security Group (NSG) in Azure is used to filter network traffic to and from Azure resources in an Azure Virtual Network. An NSG contains security rules that allow or deny inbound network traffic to, or outbound network traffic from, several types of Azure resources. This module creates five NSGs, two of which will be implemented on the Spoke Virtual Network and three of them will be implemented on the Hub Virtual Network 

# Example 
```
module "network_nsg" {
  source                = "./modules/nsg"
  resource_group_name   = azurerm_resource_group.hub.name
  resource_group_name2  = var.spoke_resource_group_name
  location              = var.location
  app_prefix            = var.app_prefix
  subscription_suffix   = var.subscription_suffix
  nsg01                 = var.nsg01
  nsg02                 = var.nsg02
  nsg03                 = var.nsg03 
  nsg04                 = var.nsg04
  nsg05                 = var.nsg05
  subnet_id01           = module.hub_network.subnet_ids["jumpbox-subnet"]
  subnet_id02           = module.spoke_network.subnet_ids["aks-subnet"]
  subnet_id03           = module.spoke_network.subnet_ids["web-subnet"]
  subnet_id04           = module.spoke_network.subnet_ids["data-subnet"]
  subnet_id05           = module.spoke_network.subnet_ids["ingress-subnet"]
 
  depends_on = [
    module.hub_network,
    module.spoke_network
  ]
}
```
### Inputs for Network Security Groups   

|      Name    |   Description    |    Type   |     Default    |    Required   |
|--------------|------------------|-----------|----------------|---------------|
|resource_group_name        | The name of the resource group 	                                                 | string | n/a	    | yes      |
|resource_group_name2	    | The name of the second resource group                                              | string | n/a	    | yes      |
|location                   | The location/region where the network security groups are created                  | string | n/a	    | yes      |
|app_prefix	                | The prefix "app"	                                                                 | string | n/a	    | yes      |
|subscription_suffix        | The suffix "subscription"                                                          | string | n/a	    | yes      |
|nsg01	                    | The name of the first network security group 	                                     | string | n/a	    | yes      |
|nsg02	                    | The name of the second network security group                                      | string | n/a	    | yes      |
|nsg03	                    | The name of the third network security group 	                                     | string | n/a	    | yes      |
|nsg04	                    | The name of the fourth network security group 	                                 | string | n/a	    | yes      |
|nsg05                     	| The name of the fifth network security group 	                                     | string | n/a	    | yes      |
|subnet_id01	            | The ID of subnet 1	                                                             | string | n/a	    | yes      |
|subnet_id02                | The ID of subnet 2                                                                 | string | n/a     | yes      |
|subnet_id03	            | The ID of subnet 3	                                                             | string | n/a	    | yes      |
|subnet_id04	            | The ID of subnet 4	                                                             | string | n/a	    | yes      |
|subnet_id05 	            | The ID of subnet 5	                                                             | string | n/a	    | yes      |




Description of NSG main.tf  

|         Name              |  Description                                                                            |
|---------------------------|-----------------------------------------------------------------------------------------|
|name 	                    |The name of the security rule                                                            |
|direction                  |"Inbound" or "Outbound"	                                                              |
|access	                    |Specifies whether network traffic is "allowed" or "denied"                               |
|priority                   |Specifies the priority of the rule 	                                                  |
|protocol                   |Network protocol this rules applies to 	                                              |
|source_port_range          |Source port or range. Integer or range between "0" and "65535" or "*" to match any.      |
|destination _port_range    |Destination port or range. Integer or range between "0" and "65535" or "*" to match any. |
|source_address_prefix	    |CIDR or source IP range or "*" to match any IP. Tags such as 'virtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used                         |
|destination_address_prefix|CIDR or destination IP range or "*" to match any IP. Tags such as 'virtualNetwork', 'AzureLoadBalancer' and 'Internet' can also be used               |
|network_security_group_name|The name of the Network Security Group that we want to attach the rule to                |
|subnet_id                  | The ID of the Subnet. Changing this forces a new resource to be created                 |
|network_security_group_id  | The ID of the Network Security Group which should be associated with the subnet         | 