data "azurerm_key_vault_key" "Diskkey" {
  name         = var.disk_key_name 
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  depends_on   = [azurerm_key_vault_key.generatedInfra]
}


data "azurerm_storage_account" "devstrgaccblob" {
  name                = var.blob_storage_account_name
  resource_group_name = azurerm_resource_group.dev_common.name
  depends_on          = [module.blobstorage]
}

data "azurerm_storage_account" "devstrgaccfile" {
  name                = var.file_storage_account_name
  resource_group_name = azurerm_resource_group.dev_common.name
  depends_on          = [module.filestorage]
}


data "azurerm_subnet" "sn_dev_app" {
  name                 = "sn_dev_app"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "RG-Dev-Infra"
  depends_on           = [module.dev_vnet]

}

data "azurerm_subnet" "sn_dev_db" {
  name                 = "sn_dev_db"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "RG-Dev-Infra"
  depends_on           = [module.dev_vnet]
}

data "azurerm_subnet" "sn_dev_gwint" {
  name                 = "sn_dev_gwint"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "RG-Dev-Infra"
  depends_on           = [module.dev_vnet]

}

data "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "RG-Dev-Infra"
  depends_on           = [module.dev_vnet]

}

data "azurerm_subnet" "DevOpsBastionSubnet" {
  name                 = "DevOpsBastionSubnet"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "RG-Dev-Infra"
  depends_on           = [module.dev_vnet]

}

data "azurerm_log_analytics_workspace" "dev-log" {
  name                = "dev-log"
  resource_group_name = data.azurerm_resource_group.dev_infra.name
  depends_on = [azurerm_log_analytics_workspace.dev-log]
  
  
}

data "azurerm_resource_group" "dev_infra" {
  name = "RG-Dev-Infra"
  depends_on = [azurerm_resource_group.dev_infra]
}
