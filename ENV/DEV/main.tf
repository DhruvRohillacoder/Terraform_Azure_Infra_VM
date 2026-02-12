module "rg" {
  source = "../../Modules/azurerm_resource_group"
    rgs = var.rgs
}

# module "vnet" {
#   source     = "../../Modules/azurerm_virtual_network"
#   depends_on = [module.rg]
# }

# module "subnet" {
#   source     = "../../Modules/azurerm_subnet"
#   depends_on = [module.vnet]
# }

# module "pip" {
#   source = "../../Modules/azurerm_public_ip"
#   depends_on = [ module.rg ]
# }