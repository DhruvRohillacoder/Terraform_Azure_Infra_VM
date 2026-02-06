module "rg" {
  source = "../../Modules/azurerm_resource_group"
  name     = "rg-dev-002"
  location = "eastus"
}