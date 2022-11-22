data "azurerm_subnet" "untrusted" {
  name                 = "smp-untrusted-subnet"
  virtual_network_name = "smp-hub-001-vnet"
  resource_group_name  = var.hub_network_resource_group_name
}

data "azurerm_subnet" "trusted" {
  name                 = "smp-trusted-subnet"
  virtual_network_name = "smp-hub-001-vnet"
  resource_group_name  = var.hub_network_resource_group_name
}
