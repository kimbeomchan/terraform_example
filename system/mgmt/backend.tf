terraform {
  backend "azurerm" {
    resource_group_name  = "demo-terraform-rg"
    storage_account_name = "demoterraformstga"
    container_name       = "demo-tfstate"
    key                  = "hub/demo/system/mgmt/hub-demo-system-mgmt.tfstate"
  }
}