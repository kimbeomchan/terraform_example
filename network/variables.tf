# keyvault 정보
variable "keyvault_resource_group_name" {
  type    = string
  default = "demo-terraform-rg"
}

variable "keyvault_name" {
  type    = string
  default = "demo-terraform-kvlt"
}

# resource group & location & tag
variable "hub_network_resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
  default     = "demo-hub-network-rg"
}

variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  type        = string
  default     = "koreacentral"
}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}

# vnet & subnet
variable "hub_vnet_name" {
  description = "Specifies the name of the hub virtual virtual network"
  default     = "demo-hub-001-vnet"
  type        = string
}

variable "hub_address_space" {
  description = "Specifies the address space of the hub virtual virtual network"
  default     = ["10.0.0.0/16"]
  type        = list(string)
}

variable "hub_trusted_subnet_nsg" {
  description = "Specifies the name of the hub virtual virtual network"
  default     = "demo-hub-trusted-nsg"
  type        = string
}

variable "hub_trusted_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.0.1.0/24"]
  type        = list(string)
}

variable "hub_untrusted_subnet_nsg" {
  description = "Specifies the name of the hub virtual virtual network"
  default     = "demo-hub-untrusted-nsg"
  type        = string
}

variable "hub_untrusted_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.0.2.0/24"]
  type        = list(string)
}

# ========
# variable "nsg_rules" {
#   type = map(object({
#       name                       = string
#       description                = string
#       priority                   = string
#       direction                  = string
#       access                     = string
#       protocol                   = string
#       source_port_range          = string
#       destination_port_range     = string
#       source_address_prefix      = string
#       destination_address_prefix = string
#     #   source_address_prefixes    = list(string)
#     #   destination_address_prefixes = list(string)
#   }))
# }
