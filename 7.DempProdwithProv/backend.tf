terraform {
backend "azurerm" {
resource_group_name  = "DemoRG"
storage_account_name = "tfvknstorage"
container_name       = "tfdemocontainer0"
key                  = "prod.terraform.tfstate"
}
}