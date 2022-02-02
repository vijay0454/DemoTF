provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name = var.resourcename
  location = var.location
}