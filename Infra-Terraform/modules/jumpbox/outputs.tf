output "id" {
  description = "Jumpbox VM ID"
  value       = azurerm_linux_virtual_machine.jumpbox.id
}

output "jumpbox_username" {
  description = "Jumpbox VM username"
  value       = var.vm_user
}
/*
output "jumpbox_password" {
  description = "Jumpbox VM admin password"
  value       = random_password.adminpassword.result
}
*/
output "jumpbox_identity" {
  description = "Jumpbox managed identity ID"
  value       = azurerm_linux_virtual_machine.jumpbox.identity.0.principal_id
}