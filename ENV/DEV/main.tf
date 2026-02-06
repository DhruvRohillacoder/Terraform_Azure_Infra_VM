module "rg" {
  source = "../../Modules/azurerm_resource_group"
  name     = "rg-dev-001"
  location = "eastus"
}