resource "azurerm_log_analytics_workspace" "dev-log" {
  name                = "dev-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_infra.name
  sku                 = "PerGB2018"
  retention_in_days   = 31
  tags                = local.common_tags
}

module "la_diag_settings" {
  source                   = "../../terraform-modules/terraform-azurerm-monitor-diagnostics"
  basename                 = "log_ws_la_ws"
  resource_id              = azurerm_log_analytics_workspace.dev-log.id
  la_id                    = azurerm_log_analytics_workspace.dev-log.id
  retention_policy_enabled = false
  retention_days           = null
  destination              = null
}
