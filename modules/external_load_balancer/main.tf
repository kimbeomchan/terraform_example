data "azurerm_resource_group" "rg_nic" {
  name = "smp-hub-fw-rg"
}

data "azurerm_network_interface" "nic" {
  for_each            = var.nic_backend_asso
  name                = each.key
  resource_group_name = data.azurerm_resource_group.rg_nic.name
}

output "network_interface_id" {
  value = { for nic in data.azurerm_network_interface.nic : nic.name => nic.id }
}

#------------------------------
# Azure Public IP (LB)
#------------------------------
resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.pip_allocation_method
  sku                 = var.pip_sku
}

#------------------------------
# Azure Load Balancer
#------------------------------
resource "azurerm_lb" "elb" {
  #for_each            = var.elbs
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.pip_sku == "Standard" ? "Standard" : var.sku

  frontend_ip_configuration {
    name                 = var.fip_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

#------------------------------
# Backend address pool (LB)
#------------------------------
resource "azurerm_lb_backend_address_pool" "backendpool" {
  for_each        = var.elb_back_pools
  name            = each.key
  loadbalancer_id = azurerm_lb.elb.id
}

#-----------------------------------------
# NIC & Backend address pool Association
#-----------------------------------------
resource "azurerm_network_interface_backend_address_pool_association" "nic_back_asso" {
  for_each                = var.nic_backend_asso
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool[each.value.backendpool_name].id
  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  ip_configuration_name   = "ip-${each.key}"
}

#------------------------------
# Probe (LB)
#------------------------------
resource "azurerm_lb_probe" "probe" {
  depends_on          = [azurerm_lb.elb]
  for_each            = var.elb_probes
  loadbalancer_id     = azurerm_lb.elb.id
  name                = each.key
  port                = each.value.elb_probe_port
  protocol            = each.value.elb_probe_protocol
  interval_in_seconds = each.value.interval_in_seconds
}

#------------------------------
# Rule (LB)
#------------------------------
resource "azurerm_lb_rule" "elb_rule" {
  depends_on                     = [azurerm_lb.elb]
  for_each                       = var.elb_rules
  name                           = each.key
  loadbalancer_id                = azurerm_lb.elb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendpool[each.value.elb_back_pool_name].id]
  probe_id                       = azurerm_lb_probe.probe[each.value.elb_probe_name].id
  protocol                       = each.value.elb_rule_protocol
  frontend_port                  = each.value.elb_rule_frontend_port
  backend_port                   = each.value.elb_rule_backend_port
  frontend_ip_configuration_name = var.fip_name
  enable_floating_ip             = each.value.enable_floating_ip
  disable_outbound_snat          = each.value.disable_outbound_snat
}
