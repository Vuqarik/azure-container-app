resource "azurerm_application_gateway" "example" {
  name                = "apiAppGateway"
  resource_group_name = azurerm_resource_group.dev-container.name
  location            = azurerm_resource_group.dev-container.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gatewayIpConfig"
    subnet_id = azurerm_subnet.sn_dev_.id
  }

  frontend_port {
    name = "port80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }

  backend_address_pool {
    name = "apiBackendPool"
  }

  backend_http_settings {
    name                  = "apiHttpSetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "apiBackendPool"
    backend_http_settings_name = "apiHttpSetting"
  }
}

