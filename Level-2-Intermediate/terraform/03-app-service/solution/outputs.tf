# =============================================================================
# Level 2.3: Outputs - Solution
# =============================================================================

output "app_service_name" {
  description = "Name of the web app"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  description = "URL of the web app"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "staging_url" {
  description = "URL of the staging slot"
  value       = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
