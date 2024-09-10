data "azurerm_subnet" "sn_bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = "dev-vnet"
  resource_group_name  = azurerm_resource_group.dev_infra.name
  depends_on           = [module.dev_vnet, azurerm_resource_group.dev_infra]

}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${local.bastion_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_infra.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.dev_infra]
}

resource "azurerm_bastion_host" "bastion" {
  name                = local.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_infra.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.sn_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  depends_on = [azurerm_public_ip.bastion_pip]
}

resource "random_string" "bastion_password" {
  length      = 48
  upper       = true
  min_upper   = 5
  lower       = true
  min_lower   = 5
  number      = true
  min_numeric = 5
  special     = false
}