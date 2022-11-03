variable "nsg_rules" {
  type        = list(map(string))
  description = "A list of maps detailing the default NSG rules."
  default = [
    {
      name                       = "module-def-in-block-vnet-all"
      direction                  = "Inbound"
      access                     = "Deny"
      priority                   = "4050"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
      destination_port_range     = "*"
    },
    {
      name                       = "module-def-out-block-vnet-all"
      direction                  = "Outbound"
      access                     = "Deny"
      priority                   = "4050"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
      destination_port_range     = "*"
    }
  ]
}