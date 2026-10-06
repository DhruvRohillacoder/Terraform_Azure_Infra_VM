terraform {
  backend "azurerm" {
    resource_group_name  = "rgdhruv"                # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "dhruvstgterraform"      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "statecont"              # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "prod.terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.5.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}


