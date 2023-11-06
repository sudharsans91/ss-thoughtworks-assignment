## Jumpbox

### Example 
```
 module "jumpbox" {
   source                  = "./modules/jumpbox"
   location                = var.location
   resource_group          = azurerm_resource_group.hub.name
   jumpbox_vm_name         = "${var.jumpbox_vm_name}-vm"
   jumpbox_vm_size         = var.jumpbox_vm_size
   vnet_id                 = module.hub_network.vnet_id
   subnet_id               = module.hub_network.subnet_ids["jumpbox-subnet"]
   dns_zone_name           = join(".", slice(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn))))
   dns_zone_resource_group = azurerm_kubernetes_cluster.privateaks.node_resource_group
   depends_on = [
     azurerm_kubernetes_cluster.privateaks,
   ]
 }
```

### Inputs for Jumpbox  

|      Name    |   Description    |    Type   |     Default    |    Required   |
|--------------|------------------|-----------|----------------|---------------|
|location 	|The location/region where the Jumpbox is created |string|n/a |yes|
|resource_group 	|The name of the resource group 	|string	|n/a |yes|
|jumpbox_vm_name	|VM and computer hostname of Jumpbox	|string	|n/a|yes|
|jumpbox_vm_size	|VM size	|string	|n/a	|yes|
|vnet_id	|ID of the VNET where Jumpbox VM will be installed |string|n/a|	yes|
|subnet_id	|ID of subnet where jumpbox VM will be installed 	|string	|n/a|yes|
|dns_zone_name	|Private DNS zone name to link the jumpbox's Vnet |string|n/a|yes
|dns_zone_resource_group	Private DNS zone resource group |	string|	n/a	|yes|
