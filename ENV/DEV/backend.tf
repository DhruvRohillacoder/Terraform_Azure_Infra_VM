terraform {
backend "azurerm" {
  resource_group_name  = "rg-titumama-1"
  storage_account_name = "sadevopsinsiders123"
  container_name       = "terraform-state"
  key                  = "countaform.tfstate"
}
}