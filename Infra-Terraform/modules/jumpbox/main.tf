resource "azurerm_public_ip" "vm_pubip" {
  name                = "${var.jumpbox_vm_name}-pubIP"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.jumpbox_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "vmNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_pubip.id
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.jumpbox_vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

/*
resource "random_password" "adminpassword" {
  keepers = {
    resource_group = var.resource_group
  }

  length      = 10
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}
*/
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                            = var.jumpbox_vm_name
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  size                            = var.jumpbox_vm_size
  computer_name                   = var.jumpbox_vm_name
  admin_username                  = "azureuser"
  admin_password                  = "ChangeMe123!"
  disable_password_authentication = false

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${var.jumpbox_vm_name}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04.0-LTS"
    version   = "latest"
  }
  
  // provisioner "remote-exec" {
  //   connection {
  //     host     = self.public_ip_address
  //     type     = "ssh"
  //     user     = var.vm_user
  //     password = random_password.adminpassword.result
  //   }

  //   inline = [
  //     "sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2",
  //     "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
  //     "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list",
  //     "sudo apt-get update",
  //     "sudo apt-get install -y kubectl",
  //     "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
  //     "wget https://vstsagentpackage.azureedge.net/agent/2.183.1/vsts-agent-linux-x64-2.183.1.tar.gz",
  //     "mkdir myagent && cd myagent",
  //     "tar zxvf ../vsts-agent-linux-x64-2.183.1.tar.gz",
  //     "./config.sh --unattended --url https://dev.azure.com/${var.org} --auth pat --token ${var.pat} --pool ${var.pool} --acceptTeeEula",
  //     "setsid run.sh >/var/log/agent.log 2>&1 < /dev/null & "
  //   ]
  // }
}
/*
resource "azurerm_private_dns_zone_virtual_network_link" "hublink" {
  name                  = "hubnetdnsconfig"
  resource_group_name   = var.dns_zone_resource_group
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.vnet_id
}
*/