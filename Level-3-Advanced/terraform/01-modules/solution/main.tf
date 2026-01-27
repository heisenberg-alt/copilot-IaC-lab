# =============================================================================
# Level 3.1: Modules - Solution
# =============================================================================

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
  features {}
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
variable "environment" {
  default = "dev"
}

variable "location" {
  default = "eastus"
}

variable "workload" {
  default = "modular"
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Networking Module
# -----------------------------------------------------------------------------
module "networking" {
  source = "../modules/networking"

  vnet_name           = "vnet-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-web" = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
    "snet-app" = {
      address_prefix    = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "snet-db" = {
      address_prefix    = "10.0.3.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }

  create_nsg = true
  tags       = local.common_tags
}

# -----------------------------------------------------------------------------
# Storage Module
# -----------------------------------------------------------------------------
module "storage" {
  source = "../modules/storage"

  storage_account_name = "st${var.workload}${var.environment}001"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location

  account_tier      = "Standard"
  replication_type  = "LRS"
  enable_versioning = true
  soft_delete_days  = 7

  container_names = ["data", "logs", "backups"]
  tags            = local.common_tags
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.networking.subnet_ids
}

output "storage_account_name" {
  description = "Storage Account Name"
  value       = module.storage.name
}

output "storage_blob_endpoint" {
  description = "Storage Blob Endpoint"
  value       = module.storage.primary_blob_endpoint
}
