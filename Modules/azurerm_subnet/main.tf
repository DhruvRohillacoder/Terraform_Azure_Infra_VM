resource "azurerm_subnet" "subnet" {
  name                 = "subnet001"
  resource_group_name  = "rg001"
  virtual_network_name = "vnet001"
  address_prefixes     = ["10.0.1.0/24"]
}