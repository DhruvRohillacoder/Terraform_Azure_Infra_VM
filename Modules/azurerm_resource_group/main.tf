resource "azurerm_resource_group" "RG" {
  for_each = var.RG
  name     = RG.name
  location = RG.location
}