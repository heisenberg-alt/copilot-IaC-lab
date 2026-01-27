# =============================================================================
# Level 1.2: Storage Account with Variables - Solution
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
# Local Values
# -----------------------------------------------------------------------------
locals {
  # Common tags applied to all resources
  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    created_by  = "copilot-iac-lab"
  }

  # Storage account name: lowercase, no hyphens, max 24 characters
  # Format: st{project}{env}{random}
  storage_name = lower(substr(replace("st${var.project_name}${var.environment}", "-", ""), 0, 24))
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "main" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Security settings
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Enable blob versioning
  blob_properties {
    versioning_enabled = true
  }

  tags = local.common_tags
}
