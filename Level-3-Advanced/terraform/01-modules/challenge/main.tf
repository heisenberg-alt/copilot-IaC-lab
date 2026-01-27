# =============================================================================
# Level 3.1: Modules - Challenge
# =============================================================================
#
# CHALLENGE: Use the provided modules to create infrastructure
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

# Variables
variable "environment" {
  default = "dev"
}

variable "location" {
  default = "eastus"
}

variable "workload" {
  default = "modular"
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# TODO: Call the networking module to create a VNet with web and app subnets


# TODO: Call the storage module to create a storage account with containers


# TODO: Create outputs for the module results

