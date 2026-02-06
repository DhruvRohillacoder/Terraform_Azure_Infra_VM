variable "name" {
    description = "The name of the virtual network."
    type        = string
    default     = "vnet001"
}
variable "resource_group_name" {
    description = "The name of the resource group in which to create the virtual network."
    type        = string    
    default     = "rg001" 
}
variable "location" {
    description = "The location/region where the virtual network will be created."
    type        = string
    default     = "eastus"
}
variable "address_space" {
    description = "The address space that is used by the virtual network."
    type        = list(string)
    default     = ["10.0.0.0/16"]
}
variable "dns_servers" {
    description = "A list of DNS server IP addresses."
    type        = list(string)
    default     = ["10.0.0.4"]
}