provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name = var.resourcename
  location = var.location
  tags = var.tags
}


data "azurerm_key_vault" "keyvault" {
  name                = "keyvaultvkn"
  resource_group_name = "DemoRG"
}
 
data "azurerm_key_vault_secret" "vmsecret" {
  name         = "tfvmpassword"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_network_security_group" "nsgruletfgroup" {
  name = "nsgrulefortfdemo"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location

dynamic "security_rule"{
iterator = rule
for_each = var.networkrule
content{
    name = rule.value.name
    priority = rule.value.priority
    direction = rule.value.direction
    access = rule.value.access
    protocol = rule.value.protocol
    source_port_range          = rule.value.source_port_range
    destination_port_range     = rule.value.destination_port_range
    source_address_prefix      = rule.value.source_address_prefix
    destination_address_prefix = rule.value.destination_address_prefix
 }
 }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "tfgroupvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "tfgroupsubnet1"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
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
   subnet_id = azurerm_subnet.subnet.id
   private_ip_address_allocation = "Dynamic"
   public_ip_address_id = azurerm_public_ip.publicip.id
 }

}

resource "azurerm_windows_virtual_machine" "vmmain" {
  name                = "TFVM"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  size                = "Standard_B2ms"
  admin_username      = "vknardas"
  admin_password      = data.azurerm_key_vault_secret.vmsecret.value
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "vm_extension_install_iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.vmmain.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
 
}
