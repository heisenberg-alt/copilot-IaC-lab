# Terraform Patterns Quick Reference

## Provider Configuration
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
```

## Variables with Validation
```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
  
  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must start with 'Standard_'."
  }
}
```

## Locals for Naming
```hcl
locals {
  name_prefix = "${var.project}-${var.environment}-${var.location}"
  
  common_tags = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}
```

## Dynamic Blocks
```hcl
variable "subnets" {
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
  }))
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "subnet" {
    for_each = var.subnets
    content {
      name             = "snet-${subnet.key}"
      address_prefixes = [subnet.value.address_prefix]
      service_endpoints = subnet.value.service_endpoints
    }
  }
}
```

## for_each with Maps
```hcl
variable "storage_accounts" {
  type = map(object({
    tier        = string
    replication = string
    access_tier = optional(string, "Hot")
  }))
}

resource "azurerm_storage_account" "accounts" {
  for_each = var.storage_accounts

  name                     = "st${each.key}${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = each.value.tier
  account_replication_type = each.value.replication
  access_tier              = each.value.access_tier
}
```

## Conditional Resources
```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}

resource "azurerm_application_insights" "main" {
  count = var.enable_monitoring ? 1 : 0

  name                = "appi-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

output "app_insights_key" {
  value = var.enable_monitoring ? azurerm_application_insights.main[0].instrumentation_key : null
}
```

## Remote State
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

data "terraform_remote_state" "networking" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "networking.terraform.tfstate"
  }
}
```

## Module Usage
```hcl
module "storage" {
  source = "./modules/storage"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  containers = ["data", "logs", "backups"]
  
  tags = local.common_tags
}

output "storage_id" {
  value = module.storage.storage_account_id
}
```
