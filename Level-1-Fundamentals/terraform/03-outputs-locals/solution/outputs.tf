# =============================================================================
# Level 1.3: Outputs - Solution
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Group Outputs
# -----------------------------------------------------------------------------
output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

# -----------------------------------------------------------------------------
# Storage Account Outputs
# -----------------------------------------------------------------------------
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_primary_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Storage Container Outputs
# -----------------------------------------------------------------------------
output "container_ids" {
  description = "Map of container names to their IDs"
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}

output "container_urls" {
  description = "Map of container names to their URLs"
  value = {
    for k, v in azurerm_storage_container.containers :
    k => "${azurerm_storage_account.main.primary_blob_endpoint}${v.name}"
  }
}

# -----------------------------------------------------------------------------
# Key Vault Outputs
# -----------------------------------------------------------------------------
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.main.name
}
