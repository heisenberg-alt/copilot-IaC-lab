# =============================================================================
# Level 2.2: Compute - Challenge
# =============================================================================
#
# CHALLENGE: Create Linux VMs with networking and cloud-init
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

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

# Subnet
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# TODO: Create Public IPs for each VM using count


# TODO: Create Network Interfaces for each VM using count


# TODO: Create Linux VMs using count with:
# - Ubuntu 22.04 LTS image
# - Standard_B2s size
# - SSH key authentication (use var.admin_ssh_key)
# - Cloud-init script to install nginx (use file() or local.cloud_init)
# - Managed OS disk

