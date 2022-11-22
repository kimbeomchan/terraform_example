# Create External Load Balancer
module "elb" {
  source              = "../../modules/external_load_balancer"
  resource_group_name = var.hub_network_resource_group_name
  location            = var.location

  lb_name               = "smp-hub-001-elb"
  pip_allocation_method = "Static"
  pip_name              = "smp-pip-lb"
  fip_name              = "smp-fip-lb"
  pip_sku               = "Standard"

  # LB Backend pool
  elb_back_pools = {
    smp-elb-001-bep = {
      backendpool_name = "smp-elb-001-bep"
    }
  }

  # NIC & Backend address pool Association
  nic_backend_asso = {
    hubfwlinux-vm-untrusted-nic-01 = {
      backendpool_name = "smp-elb-001-bep"
    }
    hubfwlinux-vm-untrusted-nic-02 = {
      backendpool_name = "smp-elb-001-bep"
    }
  }

  # LB Probes
  elb_probes = {
    smp-elb-001-probe = {
      elb_probe_port      = 80
      elb_probe_protocol  = "Tcp"
      interval_in_seconds = 15
    }
  }

  # LB Rules
  elb_rules = {
    test-elb-rule = {
      elb_back_pool_name     = "smp-elb-001-bep"
      elb_probe_name         = "smp-elb-001-probe"
      elb_rule_protocol      = "Tcp"
      elb_rule_frontend_port = 80
      elb_rule_backend_port  = 80
      enable_floating_ip     = true
      disable_outbound_snat  = true
    }
  }
}
