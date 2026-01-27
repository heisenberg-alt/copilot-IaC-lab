# =============================================================================
# Level 1.1: Hello Azure - Solution
# =============================================================================
# This configuration creates a basic Azure resource group using Terraform.
# It demonstrates provider configuration and resource creation.
# =============================================================================

# Terraform configuration block
# Specifies required Terraform version and provider dependencies
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure Provider configuration
# The features block is required even if empty
provider "azurerm" {
  features {}
}

# Resource Group
# This is the foundational resource that contains other Azure resources
resource "azurerm_resource_group" "main" {
  name     = "rg-hello-azure-dev"
  location = "eastus"

  tags = {
    environment = "dev"
    project     = "copilot-iac-lab"
    managed_by  = "terraform"
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "The location of the created resource group"
  value       = azurerm_resource_group.main.location
}
