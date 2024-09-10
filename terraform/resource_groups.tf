resource "azurerm_resource_group" "dev_infra" {
  name     = "RG-Dev-Infra"
  location = var.location
}

resource "azurerm_resource_group" "dev_common" {
  name     = "RG-Dev-Common"
  location = var.location
}

resource "azurerm_resource_group" "dev-container" {
  name     = "apiResourceGroup"
  location = "East US"
}