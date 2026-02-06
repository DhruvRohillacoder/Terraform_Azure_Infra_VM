module "rg" {
  source = "../../Modules/azurerm_resource_group"
}

module "vnet" {
  source = "../../Modules/azurerm_virtual_network"
  depends_on = [module.rg]
   
}