terraform {
  # terraform 버전은 "1.3.4"로 작성한다.(2022.10.31 현재 latest 버전)
  required_version = "1.3.4"

  required_providers {
    # azurerm provider는 "3.29.1"로 작성한다.(2022.10.31 현재 latest 버전)
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.29.1"
    }
  }
}

provider "azurerm" {
  features {}
}