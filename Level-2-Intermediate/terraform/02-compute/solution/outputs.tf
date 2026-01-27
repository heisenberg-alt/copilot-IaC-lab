# =============================================================================
# Level 2.2: Outputs - Solution
# =============================================================================

output "vm_ids" {
  description = "List of VM IDs"
  value       = azurerm_linux_virtual_machine.web[*].id
}

output "vm_names" {
  description = "List of VM names"
  value       = azurerm_linux_virtual_machine.web[*].name
}

output "public_ips" {
  description = "List of public IP addresses"
  value       = azurerm_public_ip.web[*].ip_address
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = azurerm_network_interface.web[*].private_ip_address
}

output "vm_urls" {
  description = "URLs to access the web servers"
  value       = [for ip in azurerm_public_ip.web : "http://${ip.ip_address}"]
}
