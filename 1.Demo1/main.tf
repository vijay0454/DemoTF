provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name = "DemoRG"
  location = "North Europe"
}