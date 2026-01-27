# =============================================================================
# Networking Module - Outputs
# =============================================================================

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azurerm_network_security_group.nsgs : k => v.id }
}
