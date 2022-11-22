# Create NAT Gateway
module "nat_gateway" {
  source              = "../../modules/nat_gateway"
  resource_group_name = var.hub_network_resource_group_name
  location            = var.location
  nat-gateway = {
    nat-Gateway01 = {
      public_ip_prefix_length = 31
      idle_timeout_in_minutes = 10
      vnet_name               = "smp-hub-001-vnet"
      subnet_name             = "smp-untrusted-subnet"
      subnet_id               = data.azurerm_subnet.untrusted.id
    }
  }
}

