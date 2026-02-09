variable "rg" {
  description = "The name of the resource group"
  type        = string
  default = "rg001"
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default = "eastus"
}

variable "name" {
  description = "The name of the public IP"
  type        = string
  default     = "pip001"
}

variable "allocation_method" {
  description = "The allocation method of the public IP"
  type        = string
  default     = "Static"
}