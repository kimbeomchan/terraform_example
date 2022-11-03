variable "name" {
  description = "(Required) Specifies the name of the network security group"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the network security group"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the network security group"
  type        = string
}

variable "security_rules" {
  description = "(Optional) Specifies the security rules of the network security group"
  type = map(object({
      name                       = string
      description                = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_address_prefix      = string
      source_port_range          = string
      destination_address_prefix = string
      destination_port_range     = string
  }))
}

variable "tags" {
  description = "(Optional) Specifies the tags of the network security group"
  default     = {}
}

variable "associate_subnet_id" {
  description = "(Optional) The ID of the Subnet. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

# variable "log_analytics_workspace_id" {
#   description = "Specifies the log analytics workspace resource id"
#   type        = string
# }

# variable "log_analytics_retention_days" {
#   description = "Specifies the number of days of the retention policy"
#   type        = number
#   default     = 7
# }