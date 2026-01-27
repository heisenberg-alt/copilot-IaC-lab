# =============================================================================
# Level 1.2: Storage Account with Variables - Challenge
# =============================================================================
#
# CHALLENGE: Create an Azure Storage Account using variables
#
# Use GitHub Copilot to help you complete the TODOs!
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

# TODO: Create locals block for:
# - common_tags (environment, project, managed_by)
# - storage_name (must be lowercase, no hyphens, max 24 chars)


# TODO: Create a resource group
# Name format: rg-{project_name}-{environment}


# TODO: Create a storage account with:
# - Standard tier
# - LRS replication
# - Hot access tier
# - HTTPS only
# - Blob versioning enabled (use blob_properties block)

