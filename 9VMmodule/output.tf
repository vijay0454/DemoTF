output "rgname" {
  value = azurerm_resource_group.resourcegroup.name
}



output "random_password" {
  sensitive = true  
  value = random_password.password.result
}

output "public_ip" {
  value = azurerm_public_ip.publicip.*.ip_address
}

output "virtual_machine" {
  value = azurerm_virtual_machine.vm-main.*.name
}


