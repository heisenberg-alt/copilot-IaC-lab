# =============================================================================
# Level 2.3: App Service - Challenge
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

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# TODO: Create Log Analytics Workspace for Application Insights


# TODO: Create Application Insights connected to Log Analytics


# TODO: Create App Service Plan (Linux, B1 SKU)


# TODO: Create Linux Web App with:
# - Python 3.11 runtime
# - Application Insights integration
# - App settings from variable
# - HTTPS only


# TODO: Create a staging deployment slot

