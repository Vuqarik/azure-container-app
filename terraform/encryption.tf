resource "azurerm_key_vault_key" "generatedStorage" {
  name         = var.sa_key_name
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  key_type     = "RSA"
  key_size     = "4096"

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [azurerm_key_vault_access_policy.sp_access_policy2]
}

resource "azurerm_key_vault_key" "generatedInfra" {
  name         = var.disk_key_name
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  key_type     = "RSA"
  key_size     = "4096"

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [azurerm_key_vault_access_policy.sp_access_policy2]
}

resource "azurerm_disk_encryption_set" "infra_des" {
  name                = "dev-infra-des"
  resource_group_name = azurerm_resource_group.dev_common.name
  location            = var.location
  key_vault_key_id    = data.azurerm_key_vault_key.Diskkey.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "infra-disk" {
  key_vault_id = data.azurerm_key_vault.vaultdetails.id
  tenant_id    = azurerm_disk_encryption_set.infra_des.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.infra_des.identity.0.principal_id

  key_permissions    = ["Get", "WrapKey", "UnwrapKey"]
  secret_permissions = ["Get", "List", "Delete", "Purge"]
}

