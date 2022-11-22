variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "pip_allocation_method" {
  type = string
}

variable "pip_name" {
  type = string
}

variable "fip_name" {
  type = string
}

variable "pip_sku" {
  type = string
}

variable "sku" {
  type    = string
  default = "Basic"
}

variable "elb_back_pools" {
  type = map(object({
    backendpool_name = string
  }))
}

variable "nic_backend_asso" {
  type = map(object({
    backendpool_name = string
  }))
}

variable "elb_probes" {
  type = map(object({
    elb_probe_port      = number
    elb_probe_protocol  = string
    interval_in_seconds = number
  }))
}

variable "elb_rules" {
  type = map(object({
    elb_probe_name         = string
    elb_rule_protocol      = string
    elb_back_pool_name     = string
    elb_rule_frontend_port = number
    elb_rule_backend_port  = number
    enable_floating_ip     = bool
    disable_outbound_snat  = bool
  }))
}
