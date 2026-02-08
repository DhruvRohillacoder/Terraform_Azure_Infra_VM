variable "name" {
    description = "The name of the subnet."
    type        = string
    default = "subnet001"
}

variable "resource_group_name" {
    description = "The name of the resource group in which to create the subnet."
    type        = string
    default = "rg001"
}   

variable "virtual_network_name" {
    description = "The name of the virtual network in which to create the subnet."
    type        = string
    default = "vnet001"
}

variable "address_prefixes" {
    description = "The address prefixes to use for the subnet."
    type        = list(string)
    default = ["10.0.1.0/24"]
}
