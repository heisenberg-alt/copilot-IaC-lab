# =============================================================================
# Backend Setup - Create storage for Terraform state
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

variable "location" {
  default = "eastus"
}

variable "environment" {
  default = "shared"
}

locals {
  storage_name = "sttfstate${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group for Terraform state
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate-${var.environment}"
  location = var.location

  tags = {
    purpose    = "terraform-state"
    managed_by = "terraform"
  }
}

# Storage Account for state files
resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for state files

  # Security
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }
  }

  tags = {
    purpose    = "terraform-state"
    managed_by = "terraform"
  }
}

# Container for state files
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Outputs for backend configuration
output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "backend_config" {
  description = "Backend configuration to use in other projects"
  value       = <<-EOT
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.tfstate.name}"
        storage_account_name = "${azurerm_storage_account.tfstate.name}"
        container_name       = "${azurerm_storage_container.tfstate.name}"
        key                  = "terraform.tfstate"
      }
    }
  EOT
}
