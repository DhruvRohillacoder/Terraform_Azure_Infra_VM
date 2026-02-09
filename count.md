# Terraform Count Documentation

## Table of Contents

- [Overview](#overview)
- [Basic Usage](#basic-usage)
- [Advanced Examples](#advanced-examples)
- [Best Practices](#best-practices)
- [Common Pitfalls](#common-pitfalls)
- [Count vs For_Each](#count-vs-for_each)
- [Use Cases](#use-cases)

## Overview

The `count` meta-argument in Terraform allows you to create multiple instances of a resource or module based on a numeric value. It's one of the most powerful features for managing infrastructure at scale.

### Key Characteristics

- **Type**: Integer (must be >= 0)
- **Purpose**: Create multiple similar resources
- **Index**: Each instance is identified by `count.index` (0-based)
- **Reference**: Resources are accessed as a list using bracket notation

## Basic Usage

### Simple Count Example

```hcl
resource "azurerm_resource_group" "example" {
  count    = 3
  name     = "rg-example-${count.index}"
  location = "East US"
}
```

This creates three resource groups:

- `rg-example-0`
- `rg-example-1`
- `rg-example-2`

### Dynamic Count with Variables

```hcl
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

resource "azurerm_virtual_machine" "vm" {
  count               = var.instance_count
  name                = "vm-${count.index + 1}"
  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name
  # ... additional configuration
}
```

### Conditional Count

```hcl
variable "create_resource" {
  description = "Flag to create resource"
  type        = bool
  default     = true
}

resource "azurerm_storage_account" "storage" {
  count                    = var.create_resource ? 1 : 0
  name                     = "storageaccount${count.index}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

## Advanced Examples

### Using Count with Lists

```hcl
variable "locations" {
  description = "List of Azure regions"
  type        = list(string)
  default     = ["East US", "West US", "Central US"]
}

resource "azurerm_resource_group" "regional" {
  count    = length(var.locations)
  name     = "rg-${var.locations[count.index]}"
  location = var.locations[count.index]
}
```

### Count with Element Function

```hcl
variable "vm_sizes" {
  description = "VM sizes for different tiers"
  type        = list(string)
  default     = ["Standard_B2s", "Standard_D2s_v3", "Standard_F4s_v2"]
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 5
}

resource "azurerm_virtual_machine" "vm" {
  count = var.vm_count
  name  = "vm-${count.index + 1}"

  # Cycle through VM sizes
  vm_size = element(var.vm_sizes, count.index)

  # ... additional configuration
}
```

### Count in Modules

```hcl
module "resource_group" {
  source = "./Modules/azurerm_resource_group"
  count  = 3

  resource_group_name = "rg-module-${count.index}"
  location            = "East US"
  tags = {
    Environment = "Development"
    Index       = count.index
  }
}

# Reference module outputs
output "resource_group_ids" {
  value = module.resource_group[*].resource_group_id
}
```

### Count with Local Values

```hcl
locals {
  environments = ["dev", "staging", "prod"]
  env_count    = length(local.environments)
}

resource "azurerm_resource_group" "env_rg" {
  count    = local.env_count
  name     = "rg-${local.environments[count.index]}"
  location = "East US"

  tags = {
    Environment = local.environments[count.index]
  }
}
```

## Best Practices

### 1. Use Meaningful Names

```hcl
# ✅ Good - Clear naming convention
resource "azurerm_virtual_network" "vnet" {
  count               = var.vnet_count
  name                = "vnet-${var.environment}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = ["10.${count.index}.0.0/16"]
}

# ❌ Bad - Generic naming
resource "azurerm_virtual_network" "vnet" {
  count = 3
  name  = "vnet${count.index}"
}
```

### 2. Avoid Hard-Coded Counts

```hcl
# ✅ Good - Use variables
variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 3

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 10
    error_message = "Replica count must be between 1 and 10."
  }
}

resource "azurerm_app_service" "app" {
  count = var.replica_count
  name  = "app-${count.index + 1}"
}

# ❌ Bad - Hard-coded values
resource "azurerm_app_service" "app" {
  count = 5
  name  = "app-${count.index + 1}"
}
```

### 3. Document Count Usage

```hcl
# ✅ Good - Clear documentation
variable "worker_count" {
  description = <<-EOT
    Number of worker nodes to provision.
    - Minimum: 2 for high availability
    - Maximum: 10 for cost control
    - Default: 3 for balanced setup
  EOT
  type        = number
  default     = 3
}
```

### 4. Use Splat Expressions for References

```hcl
# ✅ Good - Splat expression
output "vm_ids" {
  description = "IDs of all created VMs"
  value       = azurerm_virtual_machine.vm[*].id
}

# ❌ Less efficient - Manual list
output "vm_ids" {
  value = [
    azurerm_virtual_machine.vm[0].id,
    azurerm_virtual_machine.vm[1].id,
    azurerm_virtual_machine.vm[2].id
  ]
}
```

### 5. Implement Validation

```hcl
variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 3

  validation {
    condition     = var.subnet_count >= 1 && var.subnet_count <= 255
    error_message = "Subnet count must be between 1 and 255."
  }
}
```

## Common Pitfalls

### 1. Index-Based Ordering Issues

**Problem**: Removing an item from the middle disrupts indices.

```hcl
# Initial state
resource "azurerm_resource_group" "rg" {
  count    = 3
  name     = "rg-${count.index}"  # Creates: rg-0, rg-1, rg-2
  location = "East US"
}

# After changing count from 3 to 2
# Terraform will DELETE rg-2, not preserve rg-0 and rg-1
```

**Solution**: Use `for_each` for stable resource identities or ensure count changes only affect the end of the list.

### 2. Cannot Use Count with For_Each

```hcl
# ❌ Error - Cannot use both
resource "azurerm_storage_account" "storage" {
  count    = 3
  for_each = toset(var.environments)  # ERROR!
  # ...
}
```

### 3. Count Cannot Reference Resource Attributes

```hcl
# ❌ Error - Count must be known at plan time
resource "azurerm_subnet" "subnet" {
  count = length(azurerm_virtual_network.vnet.address_space)  # ERROR!
  # ...
}

# ✅ Solution - Use data sources or variables
variable "subnet_count" {
  description = "Number of subnets"
  type        = number
}

resource "azurerm_subnet" "subnet" {
  count = var.subnet_count
  # ...
}
```

### 4. Zero Count Edge Cases

```hcl
# When count = 0, references will fail
resource "azurerm_resource_group" "rg" {
  count    = var.create_rg ? 1 : 0
  name     = "rg-main"
  location = "East US"
}

# ❌ Error when count = 0
output "rg_name" {
  value = azurerm_resource_group.rg[0].name  # Fails if count = 0
}

# ✅ Safe reference
output "rg_name" {
  value = var.create_rg ? azurerm_resource_group.rg[0].name : null
}
```

## Count vs For_Each

### When to Use Count

- Creating multiple identical resources
- Number of resources is a simple integer
- Order doesn't matter
- Resources can be treated as a list

### When to Use For_Each

- Resources have unique identifiers
- Need stable resource addresses
- Working with maps or sets
- Resources might be added/removed from the middle

### Comparison Example

```hcl
# Using Count
variable "vm_count" {
  default = 3
}

resource "azurerm_virtual_machine" "vm_count" {
  count = var.vm_count
  name  = "vm-${count.index}"
  # ...
}

# Using For_Each
variable "vm_names" {
  default = ["web", "app", "db"]
}

resource "azurerm_virtual_machine" "vm_foreach" {
  for_each = toset(var.vm_names)
  name     = "vm-${each.value}"
  # ...
}

# Removing "app" from middle:
# - Count: Deletes vm-2, renames vm-1 → vm-2 (disruptive)
# - For_Each: Only deletes vm-app (stable)
```

## Use Cases

### 1. Multi-Region Deployment

```hcl
variable "regions" {
  description = "Azure regions for deployment"
  type        = list(string)
  default     = ["eastus", "westus", "centralus"]
}

resource "azurerm_resource_group" "regional" {
  count    = length(var.regions)
  name     = "rg-${var.regions[count.index]}"
  location = var.regions[count.index]

  tags = {
    Region      = var.regions[count.index]
    Environment = var.environment
  }
}

resource "azurerm_virtual_network" "regional" {
  count               = length(var.regions)
  name                = "vnet-${var.regions[count.index]}"
  resource_group_name = azurerm_resource_group.regional[count.index].name
  location            = azurerm_resource_group.regional[count.index].location
  address_space       = ["10.${count.index}.0.0/16"]
}
```

### 2. High Availability Setup

```hcl
variable "availability_zones" {
  description = "Number of availability zones"
  type        = number
  default     = 3
}

resource "azurerm_public_ip" "lb" {
  count               = var.availability_zones
  name                = "pip-lb-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [count.index + 1]
}
```

### 3. Environment-Specific Resources

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

# Create multiple backups only in production
resource "azurerm_backup_policy_vm" "policy" {
  count               = var.environment == "production" ? var.backup_retention_days : 0
  name                = "backup-policy-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
}
```

### 4. Scaling Web Applications

```hcl
variable "web_tier_count" {
  description = "Number of web tier instances"
  type        = number
  default     = 2

  validation {
    condition     = var.web_tier_count >= 2 && var.web_tier_count <= 10
    error_message = "Web tier must have 2-10 instances for HA."
  }
}

resource "azurerm_app_service" "web" {
  count               = var.web_tier_count
  name                = "app-web-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  app_settings = {
    "INSTANCE_ID" = count.index
    "TIER"        = "WEB"
  }
}

output "web_app_urls" {
  description = "URLs of all web applications"
  value       = [for app in azurerm_app_service.web : app.default_site_hostname]
}
```

## Summary

The `count` meta-argument is essential for:

- ✅ Creating multiple similar resources efficiently
- ✅ Conditional resource creation
- ✅ Scaling infrastructure dynamically
- ✅ Reducing code duplication

Remember:

- Use variables instead of hard-coded values
- Implement proper validation
- Consider `for_each` for resources with unique identities
- Handle zero-count edge cases
- Document your usage clearly

For complex scenarios requiring stable resource identities, consider using `for_each` instead of `count`.

---

**Last Updated**: February 2026  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: >= 3.0
