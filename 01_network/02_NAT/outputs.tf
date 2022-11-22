output "untrusted_subnet_id" {
  value = data.azurerm_subnet.untrusted.id
}

output "trusted_subnet_id" {
  value = data.azurerm_subnet.trusted.id
}

