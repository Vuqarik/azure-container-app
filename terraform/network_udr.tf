resource "azurerm_route_table" "rt_app" {
  name                = "Route Table App Subnet"
  resource_group_name = azurerm_resource_group.dev_infra.name
  location            = var.location

  route {
    name                   = "route_app001_1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.70.160.68"
  }
  route {
    name           = "route_app001_2"
    address_prefix = "10.70.170.128/25"
    next_hop_type  = "VnetLocal"
    
  }
  route {
    name           = "route_app001_3"
    address_prefix = "10.70.168.0/22"
    next_hop_type  = "VnetLocal"
    
  }

}

resource "azurerm_subnet_route_table_association" "rt_association_app_subnet" {
  subnet_id      = data.azurerm_subnet.sn_dev_app.id
  route_table_id = azurerm_route_table.rt_app.id
}

//=========================================================================================
//=========================================================================================


resource "azurerm_route_table" "rt_gwint" {
  name                = "Route Table Gwint Subnet1"
  resource_group_name = azurerm_resource_group.dev_infra.name
  location            = var.location

  route {
    name                   = "route_gwint001_1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.70.160.68"
  }
  route {
    name           = "route_gwint001_2"
    address_prefix = "10.70.171.32/27"
    next_hop_type  = "VnetLocal"
    
  }
  route {
    name           = "route_gwint001_3"
    address_prefix = "10.70.168.0/22"
    next_hop_type  = "VnetLocal"
    
  }

}

resource "azurerm_subnet_route_table_association" "rt_association_gwint_subnet" {
  subnet_id      = data.azurerm_subnet.sn_dev_gwint.id
  route_table_id = azurerm_route_table.rt_gwint.id
}


//=========================================================================================
//=========================================================================================

resource "azurerm_route_table" "rt_devopbastiont" {
  name                = "RT_SN_DevOpsBastionSubnet"
  resource_group_name = azurerm_resource_group.dev_infra.name
  location            = var.location

  route {
    name                   = "route_devopsbas_1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.70.160.68"
  }
  route {
    name           = "route_devopsbas_2"
    address_prefix = "10.70.171.128/26"
    next_hop_type  = "VnetLocal"
   
  }
  route {
    name           = "route_devopsbas_3"
    address_prefix = "10.70.168.0/22"
    next_hop_type  = "VnetLocal"
    
  }

}

resource "azurerm_subnet_route_table_association" "rt_association_DevOpsBastion_Subnet" {
  subnet_id      = data.azurerm_subnet.DevOpsBastionSubnet.id
  route_table_id = azurerm_route_table.rt_devopbastiont.id
}