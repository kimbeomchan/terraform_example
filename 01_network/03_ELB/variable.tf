variable "hub_network_resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
  default     = "smp-hub-network-rg"
}

# Location
variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  type        = string
  default     = "koreacentral"
}

# vnet & subnet
variable "prd_vnet_name" {
  description = "Specifies the name of the hub virtual virtual network"
  default     = "prd-001-vnet"
  type        = string
}

variable "hub_fw_resource_group_name" {
  type    = string
  default = "smp-hub-fw-rg"
}

variable "network_interfaces" {
  type    = list(string)
  default = ["hubfwlinux-vm-untrusted-nic-01", "hubfwlinux-vm-untrusted-nic-02"]
}
