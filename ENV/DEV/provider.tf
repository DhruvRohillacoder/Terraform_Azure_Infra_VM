terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.59.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "bf9b19d0-a2bd-49ee-9a16-6b8232861da6"
}