module "blobstorage" {
  source = "../terraform-modules/terraform-azurerm-storage/"

  name         = var.blob_storage_account_name
  storage_rsg  = azurerm_resource_group.dev_common.name
  account_kind = "StorageV2"
  account_tier = "Premium"
  # replication_type = "LRS"
  access_tier = "Hot"
  data_lake   = false

  location        = var.location
  environment     = var.environment
  tag_buildby     = var.buildby
  tag_buildticket = var.buildticket
  tag_builddate   = var.builddate
  # tag_custom      = {
  #   "CustomTag" = "Example"
  # }
}

resource "azurerm_storage_account_customer_managed_key" "storageencryption" {
  storage_account_id = data.azurerm_storage_account.devstrgaccblob.id
  key_vault_id       = data.azurerm_key_vault.vaultdetails.id
  key_name           = var.sa_key_name //data.azurerm_key_vault_key.vaultkeys.name
  depends_on         = [module.blobstorage, azurerm_key_vault_key.generatedStorage]
}

resource "azurerm_storage_account_network_rules" "networkrulescont" {
  resource_group_name  = azurerm_resource_group.dev_common.name 
  storage_account_name = var.blob_storage_account_name                      
  default_action       = "Deny"
  virtual_network_subnet_ids = [
    data.azurerm_subnet.sn_dev_app.id,
    data.azurerm_subnet.sn_dev_db.id,
    data.azurerm_subnet.sn_dev_gwint.id,
    data.azurerm_subnet.AzureBastionSubnet.id
  ]
  bypass     = ["Metrics", "AzureServices"]
  depends_on = [module.blobstorage, azurerm_resource_group.dev_common]
}

module "filestorage" {
  source = "../../terraform-modules/terraform-azurerm-storage/"

  name         = var.file_storage_account_name
  storage_rsg  = azurerm_resource_group.dev_common.name
  account_kind = "FileStorage"
  account_tier = "Premium"
  access_tier = "Hot"
  data_lake   = false

  location        = var.location
  environment     = var.environment
  tag_buildby     = var.buildby
  tag_buildticket = var.buildticket
  tag_builddate   = var.builddate
}

resource "azurerm_storage_share" "bu_storage_share" {
  name                 = "devusbu001storageshareftomd"
  storage_account_name = var.file_storage_account_name
  quota                = 150
  depends_on = [module.filestorage]
}


resource "azurerm_storage_account_customer_managed_key" "fileshareencryption" {
  storage_account_id = data.azurerm_storage_account.devstrgaccfile.id
  key_vault_id       = data.azurerm_key_vault.vaultdetails.id
  key_name           = var.sa_key_name //data.azurerm_key_vault_key.vaultkeys.name
  depends_on         = [module.filestorage, azurerm_key_vault_key.generatedStorage]
}
