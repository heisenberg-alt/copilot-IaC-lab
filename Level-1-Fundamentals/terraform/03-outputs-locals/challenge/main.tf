# =============================================================================
# Level 1.3: Outputs and Locals - Challenge
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
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
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

  tags = local.common_tags
}

# TODO: Create storage containers using for_each with local.container_names


# -----------------------------------------------------------------------------
# Key Vault (to store secrets)
# -----------------------------------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                = "kv-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Allow current user to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }

  tags = local.common_tags
}

# TODO: Create a Key Vault secret to store the storage account access key

