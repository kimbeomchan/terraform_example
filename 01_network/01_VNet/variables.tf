# keyvault info
variable "keyvault_resource_group_name" {
  type    = string
  default = "demo-terraform-rg"
}

variable "keyvault_name" {
  type    = string
  default = "demo-terraform-kvlt"
}

# common info
variable "hub_network_resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
  default     = "smp-hub-network-rg"
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

# nsg info
variable "hub_trusted_nsg_name" {
  description = "Specifies the name of the hub network security group"
  default     = "smp-hub-trusted-nsg"
  type        = string
}

variable "hub_untrusted_nsg_name" {
  description = "Specifies the name of the hub network security group"
  default     = "smp-hub-untrusted-nsg"
  type        = string
}

variable "hub_mgmt_nsg_name" {
  description = "Specifies the name of the hub network security group"
  default     = "smp-hub-mgmt-nsg"
  type        = string
}

# rt info
variable "hub_trusted_rt_name" {
  description = "Specifies the name of the hub route table"
  default     = "smp-hub-trusted-rt"
  type        = string
}

variable "hub_untrusted_rt_name" {
  description = "Specifies the name of the hub route table"
  default     = "smp-hub-untrusted-rt"
  type        = string
}

variable "hub_mgmt_rt_name" {
  description = "Specifies the name of the hub route table"
  default     = "smp-hub-mgmt-rt"
  type        = string
}