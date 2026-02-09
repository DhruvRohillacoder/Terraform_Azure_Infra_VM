  #count -> creat 10 rg with different name and location with count
resource "azurerm_resource_group" "rg" {
  count = 5
  name     = "rg-count-${count.index}"
  location = "eastus"
}