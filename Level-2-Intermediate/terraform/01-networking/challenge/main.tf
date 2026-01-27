# =============================================================================
# Level 2.1: Networking - Challenge
# =============================================================================
#
# CHALLENGE: Create a VNet with multiple subnets and NSGs
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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# TODO: Create a Virtual Network with address space 10.0.0.0/16


# TODO: Create subnets using for_each with var.subnets
# Each subnet should have name format: snet-{key}


# TODO: Create NSGs for each subnet using for_each


# TODO: Create NSG rules using nested for_each or dynamic blocks


# TODO: Associate NSGs with their respective subnets

