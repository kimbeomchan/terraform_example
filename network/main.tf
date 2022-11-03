# Create Hub Zone Network ResourceGroup
resource "azurerm_resource_group" "hub_rg" {
  name     = var.hub_network_resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Hub Zone VNet & SNet
module "hub_network" {
  source                        = "../modules/virtual_network"
  vnet_name                     = var.hub_vnet_name
  resource_group_name           = azurerm_resource_group.hub_rg.name
  location                      = azurerm_resource_group.hub_rg.location
  address_space                 = var.hub_address_space

  subnets = {
    subnet1 = {
      subnet_name             = "trusted-subnet"
      subnet_address_prefixes = var.hub_trusted_subnet_address_prefix
      delegation              = false
    }
    # },
    # subnet2 = {
    #   subnet_name             = "untrusted-subnet"
    #   subnet_address_prefixes = var.hub_untrusted_subnet_address_prefix
    #   delegation              = false
    # }
  }
}

# Create Hub Zone NSGs
module "hub_trusted_nsg" {
  source              = "../modules/network_security_group"
  name                = var.hub_trusted_subnet_nsg
  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = azurerm_resource_group.hub_rg.location
  tags                = var.tags
# }
#### 변수 처리 테스트 중 ####
  security_rules = {
    for_each = var.nsg_rules
    iterator = nsg_rules
      name                       = var.name
      direction                  = nsg.value.direction
      access                     = nsg.value.access
      priority                   = nsg.value.priority
      protocol                   = nsg.value.protocol
      source_address_prefix      = nsg.value.source_address_prefix
      destination_address_prefix = nsg.value.destination_address_prefix
      source_port_range          = nsg.value.source_port_range
      destination_port_range     = nsg.value.destination_port_range
    }
}
#### 변수 처리 테스트 중 ####
#   security_rules = {
#     in-rule01 = {
#       name                                       = "inbound_rule-001"
#       description                                = "rule"
#       priority                                   = "1000"
#       direction                                  = "Inbound"
#       access                                     = "Allow"
#       protocol                                   = "Tcp"
#       source_port_range                          = "*"
#       destination_port_range                     = "8080"
#       source_address_prefix                      = "*"
#       destination_address_prefix                 = "*"
#     },
#     in-rule02 = {
#       name                                       = "inbound_rule-002"
#       description                                = "rule"
#       priority                                   = "1100"
#       direction                                  = "Inbound"
#       access                                     = "Allow"
#       protocol                                   = "Tcp"
#       source_port_range                          = "*"
#       destination_port_range                     = "9090"
#       source_address_prefix                      = "*"
#       destination_address_prefix                 = "*"
#     }
#   }

#  module "nsg-assoc" {
# #   for_each                  = try(var.subnets, [])
# #   content{
#   subnet_id                 = var.associate_subnet_id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# #   network_security_group_id = azurerm_network_security_group.nsg[each.key].id
# #   }
# }
#   security_rules = {
#     # Inbound Rule
#     for_each = var.nsg_rules
#     # { for nsg_rules in var.nsg_rules : nsg_rules.name => nsg_rules }
#     # for_each = {for nsg_rule in var.security_rule : security_rule.network_security_group_name => security_rule1 }
#     content ={
#     name                         = each.value.name
#     description                  = each.value.description
#     priority                     = each.value.priority
#     direction                    = each.value.direction
#     access                       = each.value.access
#     protocol                     = each.value.protocol
#     source_port_range            = each.value.source_port_range
#     # source_port_ranges           = each.value.source_port_ranges
#     destination_port_range       = each.value.destination_port_range
#     # destination_port_ranges      = each.value.destination_port_ranges
#     source_address_prefix        = each.value.source_address_prefix
#     # source_address_prefixes      = each.value.source_address_prefixes
#     destination_address_prefix   = each.value.destination_address_prefix
#     # destination_address_prefixes = each.value.destination_address_prefixes
#     # resource_group_name          = azurerm_resource_group.hub_rg.name
#     # network_security_group_name  = azurerm_network_security_group.nsg.name
#     }
#   }
