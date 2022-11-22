terraform {
  backend "azurerm" {
    resource_group_name  = "rg-storageaccount"
    storage_account_name = "sabckimterraform"
    container_name       = "demo-tfstate"
    key                  = "hub/demo/network/elb/hub-demo-elb.tfstate"
  }
}
