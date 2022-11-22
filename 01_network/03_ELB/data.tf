data "azurerm_resource_group" "rg_nic" {
  name = var.hub_fw_resource_group_name
}

data "azurerm_network_interface" "nic" {
  for_each            = toset(var.network_interfaces)
  name                = each.value
  resource_group_name = var.hub_fw_resource_group_name
}

output "network_interface_id" {
  value = { for nic in data.azurerm_network_interface.nic : nic.name => nic.id }
}

