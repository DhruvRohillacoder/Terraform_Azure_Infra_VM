variable "RG" {
    type = map(object({
      name = string
      location = string
    }))
  
}