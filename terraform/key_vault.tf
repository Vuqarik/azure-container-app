data "azurerm_client_config" "current" {}

module "vault" {
  source = "../../terraform-modules/terraform-azurerm-key-vault/"
  name      = var.keyvault_name
  vault_rsg = azurerm_resource_group.dev_common.name
  location = var.location
  vault_sku = "premium"
  option_purge_protection    = true
  option_disk_encryption     = true
  option_template_deployment = true
  option_deployment          = true
}

data "azurerm_key_vault" "vaultdetails" {
  name                = var.keyvault_name
  resource_group_name = azurerm_resource_group.dev_common.name
  depends_on          = [module.vault]
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  tenant_id    = var.tenant_id
  object_id    = module.blobstorage.identitystorage 
  key_permissions    = ["get", "create", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get", "list"]
}

resource "azurerm_key_vault_access_policy" "fileshare" {
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  tenant_id    = var.tenant_id
  object_id    = module.filestorage.identityfileshare 
  key_permissions    = ["get", "create", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get", "list"]
}

resource "azurerm_key_vault_access_policy" "sp_access_policy2" {
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  tenant_id    = var.tenant_id
  object_id    =  data.azurerm_client_config.current.object_id//"a3d5830c-d2d6-4012-979c-c2425c37a834" //SP_VAZ_serviceadmin
  key_permissions         = ["get", "create", "delete", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Purge", "Backup", "Restore"]
  certificate_permissions = ["Create", "Delete", "Get", "List", "Purge"] 
 }

