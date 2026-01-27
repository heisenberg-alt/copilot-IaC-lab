# =============================================================================
# Broken Terraform - Error Fixing Demo
# =============================================================================
# This file has INTENTIONAL ERRORS for demonstration!
# Ask Copilot to fix them.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # ERROR 1: Missing version constraint
    }
  }
}

provider "azurerm" {
  # ERROR 2: Missing features block
}

# ERROR 3: Wrong variable type (should be string, not number)
variable "environment" {
  description = "Environment name"
  type        = number
  default     = "dev"
}

# ERROR 4: Missing closing brace
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"


# ERROR 5: Typo in resource type
resource "azurerm_resource_grup" "main" {
  name     = "rg-demo"
  location = var.location
}

# ERROR 6: Wrong attribute name (should be resource_group_name)
resource "azurerm_storage_account" "main" {
  name                = "stbroken123"
  resource_group      = azurerm_resource_group.main.name  # Wrong!
  location            = azurerm_resource_group.main.location
  account_tier        = "Standard"
  account_replication = "LRS"  # ERROR 7: Wrong attribute (should be account_replication_type)
}

# ERROR 8: Referencing non-existent resource
resource "azurerm_storage_container" "main" {
  name                  = "data"
  storage_account_name  = azurerm_storage.main.name  # Wrong resource name!
  container_access_type = "private"
}

# ERROR 9: Invalid output reference
output "storage_endpoint" {
  value = azurerm_storage_account.main.blob_endpoint  # Wrong attribute name!
}
