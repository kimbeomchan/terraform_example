data "azurerm_resource_group" "hub_rg" {
  name = var.hub_network_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.hub_rg.name
}

data "azurerm_subnet" "untrusted_subnet" {
  name                 = var.untrusted_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.hub_rg.name
}

data "azurerm_subnet" "trusted_subnet" {
  name                 = var.trusted_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.hub_rg.name
}
