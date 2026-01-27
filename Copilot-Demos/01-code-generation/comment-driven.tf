# =============================================================================
# Demo: Comment-Driven Code Generation
# =============================================================================
# Position your cursor after each comment and let Copilot generate the code!
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

# Create a resource group named "rg-demo-dev" in East US with environment and project tags


# Create a virtual network with address space 10.0.0.0/16


# Create three subnets: web (10.0.1.0/24), app (10.0.2.0/24), and data (10.0.3.0/24)


# Create a storage account with blob versioning and soft delete enabled


# Create an Azure Key Vault with RBAC authorization enabled

