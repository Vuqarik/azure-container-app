resource "azurerm_container_group" "example" {
  name                = "api-container-group"
  location            = azurerm_resource_group.dev-container.location
  resource_group_name = azurerm_resource_group.dev-container.name
  os_type             = "Linux"

  container {
    name   = "api-container"
    image  = "dockersamples/examplevotingapp_vote"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "public"
  ip_address {
    ports {
      protocol = "tcp"
      port     = 80
    }
  }
}
