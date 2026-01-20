# Terraform Azure Infrastructure - Virtual Machine Deployment

A complete Infrastructure-as-Code (IaC) solution for deploying and managing Azure cloud resources using Terraform. This project provides modular, reusable configurations for provisioning virtual machines, networking components, and related Azure resources across multiple environments (DEV and Production).

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Environment Management](#environment-management)
- [Modules](#modules)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Terraform project enables infrastructure provisioning on Microsoft Azure with the following capabilities:

- **Multi-Environment Support**: Separate configurations for Development and Production environments
- **Modular Architecture**: Reusable Terraform modules for resource group, virtual networks, and compute resources
- **Version Control Ready**: Git integration for infrastructure versioning and collaboration
- **Scalable Design**: Easy to extend and modify for additional resources

### Key Resources

- Azure Resource Groups
- Virtual Networks and Subnets
- Virtual Machines
- Network Security Groups
- Storage Accounts

## 📁 Project Structure

```
Terraform_Azure_Infra_VM/
├── LICENSE                          # Project license
├── README.md                        # This file
├── ENV/                             # Environment-specific configurations
│   ├── DEV/                         # Development environment
│   │   ├── main.tf                  # Main resource definitions
│   │   ├── provider.tf              # Azure provider configuration
│   │   ├── variables.tf             # Input variables (optional)
│   │   ├── outputs.tf               # Output values (optional)
│   │   └── terraform.tfvars         # Variable assignments (optional)
│   └── Prod/                        # Production environment
│       ├── main.tf
│       ├── provider.tf
│       └── ...
├── Modules/                         # Reusable Terraform modules
│   ├── azurerm_resource_group/      # Resource Group module
│   │   ├── main.tf                  # Resource definitions
│   │   ├── variables.tf             # Input variables
│   │   └── outputs.tf               # Output values
│   └── azurerm_virtual_network/     # Virtual Network module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .gitignore                       # Git ignore rules
```

## 📦 Prerequisites

Before you begin, ensure you have the following installed on your system:

1. **Terraform** (v1.0 or later)
   - Download from: https://www.terraform.io/downloads
   - Verify installation: `terraform --version`

2. **Azure CLI** (v2.0 or later)
   - Download from: https://learn.microsoft.com/cli/azure/install-azure-cli
   - Verify installation: `az --version`

3. **Azure Account**
   - Active Azure subscription
   - Appropriate permissions to create resources

4. **Git** (optional, for version control)
   - For tracking infrastructure changes

## 🚀 Getting Started

### 1. Authentication Setup

Authenticate with Azure using one of the following methods:

**Using Azure CLI:**

```powershell
az login
```

**Using Service Principal (for CI/CD pipelines):**

```powershell
$env:ARM_CLIENT_ID = "your-client-id"
$env:ARM_CLIENT_SECRET = "your-client-secret"
$env:ARM_SUBSCRIPTION_ID = "your-subscription-id"
$env:ARM_TENANT_ID = "your-tenant-id"
```

### 2. Initialize Terraform

Navigate to your environment directory and initialize Terraform:

```powershell
cd .\ENV\DEV\
terraform init
```

This command:

- Downloads required Terraform providers
- Initializes the backend for state management
- Creates the `.terraform` directory

### 3. Review Configuration

Preview the resources that will be created:

```powershell
terraform plan -out=tfplan
```

### 4. Apply Configuration

Deploy the infrastructure:

```powershell
terraform apply tfplan
```

Or apply directly:

```powershell
terraform apply
```

## ⚙️ Configuration

### Environment Variables

Create a `terraform.tfvars` file in each environment directory:

**DEV/terraform.tfvars:**

```hcl
location            = "East US"
environment         = "dev"
resource_group_name = "rg-dev-vm"
vnet_name          = "vnet-dev"
vnet_cidr           = "10.0.0.0/16"
subnet_cidr         = "10.0.1.0/24"
vm_size             = "Standard_B2s"
vm_count            = 1
```

**Prod/terraform.tfvars:**

```hcl
location            = "West US 2"
environment         = "prod"
resource_group_name = "rg-prod-vm"
vnet_name          = "vnet-prod"
vnet_cidr           = "10.100.0.0/16"
subnet_cidr         = "10.100.1.0/24"
vm_size             = "Standard_D2s_v3"
vm_count            = 2
```

### Provider Configuration

The `provider.tf` file configures the Azure provider:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## 📤 Deployment

### Development Environment

```powershell
cd .\ENV\DEV\
terraform init
terraform plan
terraform apply
```

### Production Environment

```powershell
cd .\ENV\Prod\
terraform init
terraform plan
terraform apply
```

### Destroy Infrastructure

To tear down all resources:

```powershell
terraform destroy
```

**Warning**: This will delete all managed resources permanently.

## 🔄 Environment Management

### Switching Between Environments

```powershell
# Switch to DEV
cd .\ENV\DEV\

# Switch to Production
cd .\ENV\Prod\
```

### State Management

Terraform maintains state files:

- **Local state**: `terraform.tfstate` (default)
- **Remote state**: Configure in `terraform` block for production use

**Example: Azure Blob Storage Backend**

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}
```

## 🏗️ Modules

### Resource Group Module

Manages Azure Resource Groups with tags and metadata.

**Usage:**

```hcl
module "resource_group" {
  source = "../../Modules/azurerm_resource_group"

  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
```

### Virtual Network Module

Creates virtual networks with subnets and security configurations.

**Usage:**

```hcl
module "virtual_network" {
  source = "../../Modules/azurerm_virtual_network"

  name                = var.vnet_name
  resource_group_name = module.resource_group.name
  address_space       = [var.vnet_cidr]

  subnets = [
    {
      name             = "default"
      address_prefix   = var.subnet_cidr
    }
  ]
}
```

## ✅ Best Practices

1. **State Management**
   - Use remote state for team environments (Azure Blob Storage, Terraform Cloud)
   - Enable state locking to prevent concurrent modifications
   - Store sensitive data in state carefully

2. **Security**
   - Never commit `.tfvars` files with sensitive data
   - Use Azure Key Vault for secrets
   - Implement Network Security Groups (NSGs)
   - Enable disk encryption on VMs

3. **Naming Conventions**
   - Follow Azure naming standards
   - Use consistent prefixes (e.g., `rg-`, `vnet-`)
   - Include environment indicator (dev, prod)

4. **Module Development**
   - Keep modules focused and reusable
   - Document inputs and outputs
   - Version your modules

5. **Testing & Validation**

   ```powershell
   terraform fmt                    # Format files
   terraform validate               # Validate configuration
   terraform plan -out=tfplan       # Review changes
   ```

6. **Version Control**
   - Commit `.tf` files and lock files
   - Use `.gitignore` for sensitive files
   - Tag releases for production deployments

## 🔧 Troubleshooting

### Common Issues

**Issue: "Error: Provider version constraints not satisfied"**

```powershell
rm -recurse .terraform
terraform init
```

**Issue: "Error: Subscription is not registered for resource type"**

```powershell
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Network
```

**Issue: "Authentication failed"**

```powershell
az login
az account set --subscription "subscription-id"
```

### Useful Commands

```powershell
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# Show specific resource
terraform state show module.resource_group.azurerm_resource_group.this

# Refresh state
terraform refresh

# Detailed logging
$env:TF_LOG = "DEBUG"
terraform plan
```

## 📚 Documentation & Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Learning Path](https://learn.microsoft.com/azure/)
- [Terraform Best Practices](https://www.terraform.io/language/upgrade-guides)

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## 🤝 Contributing

Contributions are welcome! Please:

1. Create a new branch for your changes
2. Test thoroughly in DEV environment first
3. Submit a pull request with detailed description

---

**Last Updated**: January 2026
**Maintainer**: [Your Name/Team]
