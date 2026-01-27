# =============================================================================
# Storage Module - Main
# =============================================================================
# This module creates an Azure Storage Account with optional containers

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  access_tier              = var.access_tier

  # Security settings
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Blob properties
  blob_properties {
    versioning_enabled = var.enable_versioning

    dynamic "delete_retention_policy" {
      for_each = var.soft_delete_days > 0 ? [1] : []
      content {
        days = var.soft_delete_days
      }
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Storage Containers
# -----------------------------------------------------------------------------
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.container_names)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
