# =============================================================================
# Level 2.1: Outputs - Solution
# =============================================================================

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = { for k, v in azurerm_network_security_group.nsgs : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes[0] }
}
