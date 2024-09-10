module "dev_vnet" {
  source = "../../terraform-modules/terraform-azurerm-vnet"

  vnet_rsg           = azurerm_resource_group.dev_infra.name
  vnet_name          = var.bu_vnet_name
  vnet_address_space = ["10.70.168.0/22"]
  

  subnet_list = var.dev_subnet_list

  tag_buildby = "me"
  location    = var.location
  environment = var.environment
  depends_on  = [azurerm_resource_group.dev_infra]
 
}
