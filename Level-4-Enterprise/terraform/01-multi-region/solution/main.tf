# =============================================================================
# Level 4.1: Multi-Region Deployment - Solution
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

variable "environment" {
  default = "prod"
}

variable "workload" {
  default = "global"
}

variable "regions" {
  description = "Map of regions for multi-region deployment"
  type = map(object({
    location = string
    is_primary = bool
  }))
  default = {
    primary = {
      location   = "eastus"
      is_primary = true
    }
    secondary = {
      location   = "westus"
      is_primary = false
    }
  }
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource Groups (one per region)
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "regional" {
  for_each = var.regions

  name     = "rg-${var.workload}-${var.environment}-${each.key}"
  location = each.value.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# App Service Plans (one per region)
# -----------------------------------------------------------------------------
resource "azurerm_service_plan" "regional" {
  for_each = var.regions

  name                = "asp-${var.workload}-${each.key}"
  resource_group_name = azurerm_resource_group.regional[each.key].name
  location            = azurerm_resource_group.regional[each.key].location
  os_type             = "Linux"
  sku_name            = "P1v3"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Web Apps (one per region)
# -----------------------------------------------------------------------------
resource "azurerm_linux_web_app" "regional" {
  for_each = var.regions

  name                = "app-${var.workload}-${each.key}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.regional[each.key].name
  location            = azurerm_service_plan.regional[each.key].location
  service_plan_id     = azurerm_service_plan.regional[each.key].id

  https_only = true

  site_config {
    always_on = true
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    "REGION"      = each.key
    "ENVIRONMENT" = var.environment
  }

  tags = local.common_tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Azure Front Door for Global Load Balancing
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "frontdoor" {
  name     = "rg-${var.workload}-frontdoor"
  location = "eastus"
  tags     = local.common_tags
}

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "fd-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.frontdoor.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.common_tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-${var.workload}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "og-${var.workload}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "regional" {
  for_each = var.regions

  name                          = "origin-${each.key}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id

  enabled                        = true
  host_name                      = azurerm_linux_web_app.regional[each.key].default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_linux_web_app.regional[each.key].default_hostname
  priority                       = each.value.is_primary ? 1 : 2
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-${var.workload}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [for o in azurerm_cdn_frontdoor_origin.regional : o.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "regional_app_urls" {
  value = { for k, v in azurerm_linux_web_app.regional : k => "https://${v.default_hostname}" }
}

output "front_door_url" {
  value = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
}
