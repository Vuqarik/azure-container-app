resource "azurerm_network_security_group" "Base_NSG" {
  name                = "NSG_BU001_ftomd_vaz"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_infra.name
}
