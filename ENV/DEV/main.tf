module "rg" {
  source = "../../Modules/azurerm_resource_group"
}

module "vnet" {
  depends_on = [module.rg]
  source     = "../../Modules/azurerm_virtual_network"

}

module "subnet" {
  depends_on = [module.vnet]
  source     = "../../Modules/azurerm_subnet"

}

module "pip" {
  source     = "../../Modules/azurerm_public_ip"
  depends_on = [module.rg]

}


