# =============================================================================
# Level 2.3: App Service - Solution
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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Log Analytics & Application Insights
# -----------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# App Service Plan
# -----------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Web App
# -----------------------------------------------------------------------------
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.workload}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only = true

  site_config {
    always_on = false # B1 doesn't support always_on

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = merge(var.app_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.main.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.main.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  })

  tags = local.common_tags
}

# Random suffix for globally unique name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Staging Slot
# -----------------------------------------------------------------------------
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = merge(var.app_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.main.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.main.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "ENVIRONMENT"                                = "staging"
  })

  tags = local.common_tags
}
