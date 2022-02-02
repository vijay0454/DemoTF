provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.resourcename
  location = var.location
  tags = var.tags
}


resource "azurerm_network_security_group" "nsgvknrule" {
  name = "azurevknnetworksecuritygrouprules"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location


  dynamic "security_rule"{
  iterator = rule
  for_each = var.networkrule
  content {
    name                       = rule.value.name
    priority                   = rule.value.priority
    direction                  = rule.value.direction
    access                     = rule.value.access
    protocol                   = rule.value.protocol
    source_port_range          = rule.value.source_port_range
    destination_port_range     = rule.value.destination_port_range
    source_address_prefix      = rule.value.source_address_prefix
    destination_address_prefix = rule.value.destination_address_prefix
  }
  }
}


resource "azurerm_virtual_network" "azvnet" {
  name = "azuretfvnet"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  address_space = [element(var.address_space,0)]
}

resource "azurerm_subnet" "azsubnet" {
  name                 = "subnetfortfcourse"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefix       = element(var.address_space,3)
}

resource "azurerm_public_ip" "publicip"{
  name = "publicipprovisioner"
  location = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "nic" {
  name = "vm-nicprovisioner"
  location = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

 ip_configuration {
   name = "testconfig"
   subnet_id = azurerm_subnet.azsubnet.id
   private_ip_address_allocation = "Dynamic"
   public_ip_address_id = azurerm_public_ip.publicip.id
 }

}

resource "random_password" "password" {
  length = 8
  special = true
}

resource "azurerm_virtual_machine" "vm-main" {
  count                 = 1
  name                  = "azurevmforprov"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = azurerm_network_interface.nic.*.id
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = random_password.password.result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = merge(var.tags,var.tag2)

}
